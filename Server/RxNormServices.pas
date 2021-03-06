unit RxNormServices;

interface

uses
  SysUtils, Classes,
  StringSupport, AdvObjects, AdvObjectLists,
  YuStemmer,
  KDBManager,
  FHIRTypes, FHIRComponents, FHIRResources, TerminologyServices, DateAndTime;

type
  TUMLSConcept = class (TCodeSystemProviderContext)
  private
    FCode : string;
    FDisplay : String;
    FOthers : TStringList;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

  TUMLSFilter = class (TCodeSystemProviderFilterContext)
  private
    sql : String;
    text : boolean;
    qry : TKDBConnection;
  public
    Destructor Destroy; Override;
  end;

  TUMLSPrep = class (TCodeSystemProviderFilterPreparationContext)
  private
    filters : TAdvObjectList;
  public
    Constructor Create; Override;
    Destructor Destroy; Override;
  end;

  TUMLSServices = class (TCodeSystemProvider)
  private
    nci : boolean;
    dbprefix : string;
    db : TKDBManager;
    rels : TStringList;
    reltypes : TStringList;

    procedure load(list : TStringList; sql : String);
  public
    Constructor Create(nci : boolean; db : TKDBManager);
    Destructor Destroy; Override;
    Function Link : TUMLSServices; overload;

    function TotalCount : integer;  override;
    function ChildCount(context : TCodeSystemProviderContext) : integer; override;
    function getcontext(context : TCodeSystemProviderContext; ndx : integer) : TCodeSystemProviderContext; override;
//    function system(context : TCodeSystemProviderContext) : String; override;
    function getDisplay(code : String):String; override;
    function getDefinition(code : String):String; override;
    function locate(code : String) : TCodeSystemProviderContext; override;
    function locateIsA(code, parent : String) : TCodeSystemProviderContext; override;
    function IsAbstract(context : TCodeSystemProviderContext) : boolean; override;
    function Code(context : TCodeSystemProviderContext) : string; override;
    function Display(context : TCodeSystemProviderContext) : string; override;
    procedure Displays(code : String; list : TStringList); override;
    procedure Displays(context : TCodeSystemProviderContext; list : TStringList); override;
    function Definition(context : TCodeSystemProviderContext) : string; override;

    function getPrepContext : TCodeSystemProviderFilterPreparationContext; override;
    function prepare(prep : TCodeSystemProviderFilterPreparationContext) : boolean; override;

    function searchFilter(filter : TSearchFilterText; prep : TCodeSystemProviderFilterPreparationContext) : TCodeSystemProviderFilterContext; override;
    function filter(prop : String; op : TFhirFilterOperator; value : String; prep : TCodeSystemProviderFilterPreparationContext) : TCodeSystemProviderFilterContext; override;
    function filterLocate(ctxt : TCodeSystemProviderFilterContext; code : String) : TCodeSystemProviderContext; override;
    function FilterMore(ctxt : TCodeSystemProviderFilterContext) : boolean; override;
    function FilterConcept(ctxt : TCodeSystemProviderFilterContext): TCodeSystemProviderContext; override;
    function InFilter(ctxt : TCodeSystemProviderFilterContext; concept : TCodeSystemProviderContext) : Boolean; override;
    function isNotClosed(textFilter : TSearchFilterText; propFilter : TCodeSystemProviderFilterContext = nil) : boolean; override;

    procedure Close(ctxt : TCodeSystemProviderFilterPreparationContext); override;
    procedure Close(ctxt : TCodeSystemProviderContext); override;
    procedure Close(ctxt : TCodeSystemProviderFilterContext); override;
  end;

  TRxNormServices = class (TUMLSServices)
  public
    Constructor Create(db : TKDBManager);
    function system(context : TCodeSystemProviderContext) : String; override;
  end;

  TNciMetaServices = class (TUMLSServices)
  public
    Constructor Create(db : TKDBManager);
    function system(context : TCodeSystemProviderContext) : String; override;
  end;

procedure generateRxStems(db : TKDBManager);

implementation

procedure MakeStems(stemmer : TYuStemmer_8; stems : TStringList; desc : String; cui : string);
var
  s : String;
  i : integer;
  list : TStringList;
begin
  while (desc <> '') do
  begin
    StringSplit(desc, [' ', '.', ',', '-', ')', '(', '#', '/', '%', '[', ']', '{', '}', ':', '@'], s, desc);
    s := StringTrimSet(s, ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']).ToLower;
    if (s <> '') and not StringIsInteger16(s) and (s[1] >= 'a') then
    begin
      s := stemmer.calc(s);
      if stems.Find(s, i) then
        TStringList(stems.Objects[i]).add(cui)
      else
      begin
        list := TStringList.Create;
        list.Sorted := true;
        list.Add(cui);
        stems.AddObject(s, list);
      end;
    end;
  end;
end;

procedure generateRxStems(db : TKDBManager);
var
  stems, list : TStringList;
  qry : TKDBConnection;
  stemmer : TYuStemmer_8;
  i, j : integer;
begin
  stemmer := GetStemmer_8('english');
  stems := TStringList.Create;
  try
    stems.Sorted := true;
    qry := db.GetConnection('stems');
    try
      qry.ExecSQL('delete from rxnstems');

      qry.SQL := 'select RXCUI, STR from rxnconso where SAB = ''RXNORM'''; // allow SY
      qry.Prepare;
      qry.Execute;
      i := 0;
      write('Stemming');
      while qry.FetchNext do
      begin
        makeStems(stemmer, stems, qry.ColString[2], qry.ColString[1]);
        inc(i);
        if (i mod 10000 = 0) then
          write('.');
      end;
      writeln('done');
      writeln(inttostr(stems.Count)+' stems');
      qry.Terminate;

      qry.SQL := 'insert into rxnstems (stem, cui) values (:stem, :cui)';
      qry.Prepare;
      write('Storing');
      for i := 0 to stems.count - 1 do
      begin
        list := stems.objects[i] as TStringList;
        for j := 0 to list.count-1 do
        begin
          qry.BindString('stem', copy(stems[i], 1, 20));
          qry.BindString('cui', list[j]);
          qry.Execute;
        end;
        if (i mod 100 = 0) then
          write('.');
      end;
      writeln('done');
      qry.Terminate;
      qry.Release;
    except
      on e : Exception do
      begin
        qry.Error(e);
        raise;
      end;
    end;
  finally
    stems.Free;
    stemmer.Free;
    db.free;
  end;
end;

{ TUMLSServices }

Constructor TUMLSServices.create(nci : boolean; db : TKDBManager);
begin
  inherited Create;

  self.nci := nci;
  if (nci) then
    dbprefix := 'NciMeta'
  else
    dbprefix := 'RxNorm';
  self.db := db;
  rels := TStringList.create;
  reltypes := TStringList.create;

  if (TotalCount = 0) then
    raise Exception.Create('Error Connecting to RxNorm');
  load(rels, 'select distinct REL from RXNREL');
  load(reltypes, 'select distinct RELA from RXNREL');
end;



function TUMLSServices.TotalCount : integer;
var
  qry : TKDBConnection;
begin
  qry := db.GetConnection(dbprefix+'.Count');
  try
    qry.SQL := 'Select Count(*) from rxnconso where SAB = ''RXNORM'' and TTY <> ''SY''';
    qry.prepare;
    qry.execute;
    qry.FetchNext;
    result := qry.ColInteger[1];
    qry.Terminate;
    qry.Release;
  except
    on e : Exception do
    begin
      qry.Error(e);
      raise;
    end;
  end;
end;


function TUMLSServices.getDefinition(code: String): String;
begin
  result := '';
end;

function TUMLSServices.getDisplay(code : String):String;
var
  qry : TKDBConnection;
begin
  qry := db.GetConnection(dbprefix+'.display');
  try
    qry.SQL := 'Select STR from rxnconso where RXCUI = :code and SAB = ''RXNORM'' and TTY <> ''SY''';
    qry.prepare;
    qry.execute;
    qry.FetchNext;
    result := qry.colString[1];
    qry.Terminate;
    qry.Release;
  except
    on e : Exception do
    begin
      qry.Error(e);
      raise;
    end;
  end;
end;

function TUMLSServices.getPrepContext: TCodeSystemProviderFilterPreparationContext;
begin
  result := TUMLSPrep.Create;
end;

procedure TUMLSServices.Displays(code : String; list : TStringList);
begin
  list.Add(getDisplay(code));
end;


{
 TCodeSystemProviderContext methods

 a TCodeSystemProviderContext is a reference to a code (A CUI in RXNrom) that is
 used to get information about the code
}

procedure TUMLSServices.load(list: TStringList; sql: String);
var
  qry : TKDBConnection;
begin
  qry := db.GetConnection(dbprefix+'.display');
  try
    qry.SQL := sql;
    qry.prepare;
    qry.Execute;
    while qry.FetchNext do
      list.add(qry.ColString[1]);
    qry.Terminate;
    qry.Release;
  except
    on e : Exception do
    begin
      qry.Error(e);
      raise;
    end;
  end;
end;

function TUMLSServices.locate(code : String) : TCodeSystemProviderContext;
var
  qry : TKDBConnection;
  res : TUMLSConcept;
begin
  qry := db.GetConnection(dbprefix+'.display');
  try
    qry.SQL := 'Select STR, TTY from rxnconso where RXCUI = :code and SAB = ''RXNORM''';
    qry.prepare;
    qry.bindString('code', code);
    qry.execute;
    if not qry.FetchNext then
      result := nil
    else
    begin
      res := TUMLSConcept.Create;
      try
        res.FCode := code;
        repeat
          if qry.ColString[2] = 'SY' then
            res.FOthers.Add(qry.ColString[1])
          else
            res.FDisplay := qry.ColString[1];
        until (not qry.FetchNext);
        result := res.Link;
      finally
        res.Free;
      end;
    end;
    qry.Terminate;
    qry.Release;
  except
    on e : Exception do
    begin
      qry.Error(e);
      raise;
    end;
  end;
end;


function TUMLSServices.Code(context : TCodeSystemProviderContext) : string;
begin
  result := TUMLSConcept(context).FCode;
end;

function TUMLSServices.Definition(context: TCodeSystemProviderContext): string;
begin
  result := '';
end;

destructor TUMLSServices.Destroy;
begin
  DB.Free;
  rels.free;
  reltypes.free;
  inherited;
end;

function TUMLSServices.Display(context : TCodeSystemProviderContext) : string;
begin
  result := TUMLSConcept(context).FDisplay;
end;

procedure TUMLSServices.Displays(context: TCodeSystemProviderContext; list: TStringList);
begin
  list.Add(Display(context));
  list.AddStrings(TUMLSConcept(context).FOthers);
end;

function TUMLSServices.IsAbstract(context : TCodeSystemProviderContext) : boolean;
begin
  result := false;  // RxNorm doesn't do abstract?
end;

function TUMLSServices.isNotClosed(textFilter: TSearchFilterText; propFilter: TCodeSystemProviderFilterContext): boolean;
begin
  result := false;
end;

function TUMLSServices.Link: TUMLSServices;
begin
  result := TUMLSServices(Inherited Link);
end;

function TUMLSServices.ChildCount(context : TCodeSystemProviderContext) : integer;
begin
  raise Exception.Create('ChildCount not supported by RXNorm'); // only used when iterating the entire code system. and RxNorm is too big
end;

function TUMLSServices.getcontext(context : TCodeSystemProviderContext; ndx : integer) : TCodeSystemProviderContext;
begin
  raise Exception.Create('getcontext not supported by RXNorm'); // only used when iterating the entire code system. and RxNorm is too big
end;

function TUMLSServices.locateIsA(code, parent : String) : TCodeSystemProviderContext;
begin
  result := nil; // todo: no sumbsumption?
end;


function TUMLSServices.prepare(prep : TCodeSystemProviderFilterPreparationContext) : boolean;
var
  sql1 : string;
  sql2 : String;
  i : integer;
  filter : TUMLSFilter;
begin
  result := false;
  if TUMLSPrep(prep).filters.Count = 0 then
    exit; // not being used

  sql1 := '';
  sql2 := 'from rxnconso';

  for i := 0 to TUMLSPrep(prep).filters.Count - 1 do
    if not TUMLSFilter(TUMLSPrep(prep).filters[i]).text then
      sql1 := sql1 + ' '+TUMLSFilter(TUMLSPrep(prep).filters[i]).sql;
  for i := 0 to TUMLSPrep(prep).filters.Count - 1 do
  begin
    if TUMLSFilter(TUMLSPrep(prep).filters[i]).text then
    begin
      sql2 := sql2 + ', rxnstems as s'+inttostr(i);
      sql1 := sql1 + ' '+TUMLSFilter(TUMLSPrep(prep).filters[i]).sql.replace('%%', inttostr(i));
    end;
  end;

  filter := TUMLSFilter(TUMLSPrep(prep).filters[0]);
  filter.sql := sql1;
  result := true;
  filter.qry := db.GetConnection(dbprefix+'.prepare');
  filter.qry.SQL := 'Select RXCUI, STR '+sql2+' where SAB = ''RXNORM'' and TTY <> ''SY'' '+filter.sql;
  filter.qry.Prepare;
  filter.qry.Execute;
end;

function TUMLSServices.searchFilter(filter : TSearchFilterText; prep : TCodeSystemProviderFilterPreparationContext) : TCodeSystemProviderFilterContext;
var
  s : String;
  i : integer;
  res : TUMLSFilter;
begin
  if prep = nil then
  begin
    // in this case, a search through the entire rxnorm. nothing to do to speed it up, and it won't be prepped
    s := '';
    for i := 0 to filter.stems.Count - 1 do
      s := s +' and RXCUI in (select CUI from rxnstems where stem like '''+SQLWrapString(filter.stems[i])+'%'')';

    res := TUMLSFilter.Create;
    try
      res.sql := s;
      result := res.link;
    finally
      res.Free;
    end;
  end
  else
  begin
    result := nil;
    for i := 0 to filter.stems.Count - 1 do
    begin
      res := TUMLSFilter.Create;
      try
        res.sql := ' and (RXCUI = s%%.CUI and s%%.stem like '''+SQLWrapString(filter.stems[i])+'%'')';
        res.text := true;
        if result = nil then
          result := res.link;
        TUMLSPrep(prep).filters.Add(res.Link);
      finally
        res.Free;
      end;
    end;
  end;
end;

function TUMLSServices.filter(prop : String; op : TFhirFilterOperator; value : String; prep : TCodeSystemProviderFilterPreparationContext) : TCodeSystemProviderFilterContext;
var
  res : TUMLSFilter;
  ok : boolean;
begin
  result := nil;

  res := TUMLSFilter.Create;
  try
    ok := true;
    if (op = FilterOperatorIn) and (prop = 'TTY') then
      res.sql := 'and TTY in ('+SQLWrapStrings(value)+')'
    else if (op <> FilterOperatorEqual) then
      ok := false
    else if prop = 'STY' then
      res.sql := 'and RXCUI in (select RXCUI from rxnsty where TUI = '''+SQLWrapString(value)+''')'
    else if prop = 'SAB' then
      res.sql := 'and RXCUI in (select RXCUI from rxnconso where SAB = '''+SQLWrapString(value)+'''))'
    else if prop = 'TTY' then
      res.sql := 'and TTY =  '''+SQLWrapString(value)+''''
    else if (rels.indexof(prop) > -1) and value.StartsWith('CUI:') then
      res.sql := 'and (RXCUI in (select RXCUI from rxnconso where RXCUI in (select RXCUI1 from rxnrel where '+
      'REL = '''+SQLWrapString(prop)+''' and RXCUI2 = '''+SQLWrapString(value.Substring(4))+'''))'
    else if (rels.indexof(prop) > -1) and value.StartsWith('AUI:') then
      res.sql := 'and (RXCUI in (select RXCUI from rxnconso where '+
      'RXAUI in (select RXAUI1 from rxnrel where REL = '''+SQLWrapString(prop)+''' and RXAUI2 = '''+SQLWrapString(value.Substring(4))+'''))'
    else if (reltypes.indexof(prop) > -1) and value.StartsWith('CUI:') then
      res.sql := 'and (RXCUI in (select RXCUI from rxnconso where '+
      'RXCUI in (select RXCUI1 from rxnrel where '+
      'RELA = '''+SQLWrapString(prop)+''' and RXCUI2 = '''+SQLWrapString(value.Substring(4))+'''))'
    else if (reltypes.indexof(prop) > -1) and value.StartsWith('AUI:') then
      res.sql := 'and (RXCUI in (select RXCUI from rxnconso where '+
      'RXAUI in (select RXAUI1 from rxnrel where RELA = '''+SQLWrapString(prop)+''' and RXAUI2 = '''+SQLWrapString(value.Substring(4))+'''))'
    else
      ok := false;
    if ok then
    begin
      result := res.link;
      if prep <> nil then
        TUMLSPrep(prep).filters.Add(res.Link);
    end
    else
      raise Exception.Create('Unknown filter ');
  finally
    res.Free;
  end;
end;

function TUMLSServices.filterLocate(ctxt : TCodeSystemProviderFilterContext; code : String) : TCodeSystemProviderContext;
var
  qry : TKDBConnection;
  res : TUMLSConcept;
begin
  qry := db.GetConnection(dbprefix+'.locate');
  try
    qry.SQL := 'Select RXCUI, STR from rxnconso where SAB = ''RXNORM''  and TTY <> ''SY'' and RXCUI = :code '+TUMLSFilter(ctxt).sql;
    qry.prepare;
    qry.BindString('code', code);
    qry.execute;
    if not qry.FetchNext then
      result := nil
    else
    begin
      res := TUMLSConcept.Create;
      try
        res.FCode := code;
        res.FDisplay := qry.ColString[2];
        result := res.Link;
      finally
        res.Free;
      end;
    end;
    qry.Terminate;
    qry.Release;
  except
    on e : Exception do
    begin
      qry.Error(e);
      raise;
    end;
  end;
end;

function TUMLSServices.FilterMore(ctxt : TCodeSystemProviderFilterContext) : boolean;
var
  filter : TUMLSFilter;
begin
  filter := TUMLSFilter(ctxt);
  if (filter.qry = nil) then
  begin
    // search on full rxnorm
    filter.qry := db.GetConnection(dbprefix+'.filter');
    filter.qry.SQL := 'Select RXCUI, STR from rxnconso where SAB = ''RXNORM'' and TTY <> ''SY'' '+filter.sql;
    filter.qry.prepare;
    filter.qry.Execute;
  end;
  result := filter.qry.FetchNext;
end;

function TUMLSServices.FilterConcept(ctxt : TCodeSystemProviderFilterContext): TCodeSystemProviderContext;
var
  filter : TUMLSFilter;
  res : TUMLSConcept;
begin
  filter := TUMLSFilter(ctxt);
  res := TUMLSConcept.Create;
  try
    res.FCode := filter.qry.ColString[1];
    res.FDisplay := filter.qry.ColString[2];
    result := res.Link;
  finally
    res.Free;
  end;
end;

function TUMLSServices.InFilter(ctxt : TCodeSystemProviderFilterContext; concept : TCodeSystemProviderContext) : Boolean;
begin
  raise Exception.Create('Error in internal logic - filter not prepped?');
end;

procedure TUMLSServices.Close(ctxt: TCodeSystemProviderContext);
begin
  ctxt.free;
end;

procedure TUMLSServices.Close(ctxt : TCodeSystemProviderFilterContext);
begin
  ctxt.free;
end;



procedure TUMLSServices.Close(ctxt: TCodeSystemProviderFilterPreparationContext);
var
  filter : TUMLSFilter;
begin
  filter := TUMLSFilter(TUMLSPrep(ctxt).filters[0]);
  filter.qry.release;

end;

{ TUMLSPrep }

constructor TUMLSPrep.Create;
begin
  inherited;
  filters := TAdvObjectList.Create;
end;

destructor TUMLSPrep.Destroy;
begin
  filters.Free;
  inherited;
end;

{ TUMLSFilter }

destructor TUMLSFilter.Destroy;
begin
  if (qry <> nil) then
  begin
    qry.terminate;
    qry.Release;
  end;
  inherited;
end;

{ TUMLSConcept }

constructor TUMLSConcept.create;
begin
  inherited;
  FOthers := TStringList.Create;
end;

destructor TUMLSConcept.destroy;
begin
  FOthers.free;
  inherited;
end;

{ TRxNormServices }

constructor TRxNormServices.Create(db: TKDBManager);
begin
  inherited create(false, db);
end;

function TRxNormServices.system(context: TCodeSystemProviderContext): String;
begin
  result := 'http://www.nlm.nih.gov/research/umls/rxnorm';
end;

{ TNciMetaServices }

constructor TNciMetaServices.Create(db: TKDBManager);
begin
  inherited create(true, db);
end;

function TNciMetaServices.system(context: TCodeSystemProviderContext): String;
begin
  result := 'http://ncimeta.nci.nih.gov';
end;

end.
