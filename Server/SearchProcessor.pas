unit SearchProcessor;

interface

uses
  SysUtils, Classes, Generics.Collections,
  ParseMap,
  StringSupport, EncodeSupport,
  AdvObjects, DateAndTime, DecimalSupport,
  FHIRBase, FHIRResources, FHIRLang, FHIRConstants, FHIRComponents, FHIRTypes,
  FHIRIndexManagers, FHIRDataStore, FHIRUtilities, FHIRSearchSyntax, FHIRSupport,
  UcumServices;

const
  SEARCH_PARAM_NAME_ID = 'search-id';
  HISTORY_PARAM_NAME_ID = 'history-id';
  SEARCH_PARAM_NAME_OFFSET = 'search-offset';
  SEARCH_PARAM_NAME_TEXT = '_text';
  SEARCH_PARAM_NAME_COUNT = '_count';
  SEARCH_PARAM_NAME_SORT = 'search-sort';
  SEARCH_PARAM_NAME_SUMMARY = '_summary';
  SEARCH_PARAM_NAME_FILTER = '_filter';
  SEARCH_PAGE_DEFAULT = 50;
  SEARCH_PAGE_LIMIT = 1000;
  SUMMARY_SEARCH_PAGE_LIMIT = 10000;
  SUMMARY_TEXT_SEARCH_PAGE_LIMIT = 10000;


type
  TDateOperation = (dopEqual, dopLess, dopLessEqual, dopGreater, dopGreaterEqual);
  TQuantityOperation = (qopEqual, qopLess, qopLessEqual, qopGreater, qopGreaterEqual, qopApproximate);
  TFHIRSearchSummary = (ssFull, ssSummary, ssText);

  TSearchProcessor = class (TAdvObject)
  private
    FLink: String;
    FSort: String;
    FFilter: String;
    FTypeKey: integer;
    FCompartmentId: String;
    FCompartments: String;
    FParams: TParseMap;
    FType: TFHIRResourceType;
    FBaseURL: String;
    FWantSummary: TFHIRSearchSummary;
    FIndexer: TFhirIndexManager;
    FLang: String;
    FRepository: TFHIRDataStore;
    FSession : TFhirSession;

    function processValueSetMembership(vs : String) : String;
    function BuildFilter(filter : TFSFilter; parent : char; issuer : TFSCharIssuer; types : TFHIRResourceTypeSet) : String;
    function BuildFilterParameter(filter : TFSFilterParameter; path : TFSFilterParameterPath; parent : char; issuer : TFSCharIssuer; types : TFHIRResourceTypeSet) : String;
    function BuildFilterLogical  (filter : TFSFilterLogical;   parent : char; issuer : TFSCharIssuer; types : TFHIRResourceTypeSet) : String;
    Function ProcessSearchFilter(value : String) : String;
    Function ProcessParam(types : TFHIRResourceTypeSet; name : String; value : String; nested : boolean; var bFirst : Boolean; var bHandled : Boolean) : String;
    procedure SetIndexer(const Value: TFhirIndexManager);
    procedure SetRepository(const Value: TFHIRDataStore);
    procedure SplitByCommas(value: String; list: TStringList);
    function findPrefix(var value: String; subst: String): boolean;
    procedure checkDateFormat(s : string);
    function BuildParameterNumber(index: Integer; n: Char; j: string; name : String; op : TFSCompareOperation; value: string) : String;
    function BuildParameterString(index: Integer; n: Char; j: string; name : String; op : TFSCompareOperation; value: string) : String;
    function buildParameterDate(index: Integer; n: Char; j: string; name : String; op : TFSCompareOperation; value: string) : String;
    function buildParameterToken(index: Integer; n: Char; j: string; name : String; op : TFSCompareOperation; value: string) : String;
    function buildParameterReference(index: Integer; n: Char; j: string; name : String; op : TFSCompareOperation; value: string) : String;
    procedure replaceNames(paramPath : TFSFilterParameterPath; components : TDictionary<String, String>); overload;
    procedure replaceNames(filter : TFSFilter; components : TDictionary<String, String>); overload;
    procedure processQuantityValue(name, lang: String; parts: TArray<string>; op: TQuantityOperation; var minv, maxv, space, mincv, maxcv, spaceC: String);
    procedure SetSession(const Value: TFhirSession);
    function filterTypes(types: TFHIRResourceTypeSet): TFHIRResourceTypeSet;
  public
    Destructor Destroy; override;
    procedure Build;
//procedure TFhirOperation.ProcessDefaultSearch(typekey : integer; aType : TFHIRResourceType; params : TParseMap; baseURL, compartments, compartmentId : String; id, key : string; var link, sql : String; var total : Integer; var wantSummary : boolean);

    // inbound
    property typekey : integer read FTypeKey write FTypeKey;
    property type_ : TFHIRResourceType read FType write FType;
    property compartmentId : String read FCompartmentId write FCompartmentId;
    property compartments : String read FCompartments write FCompartments;
    property baseURL : String read FBaseURL write FBaseURL;
    property lang : String read FLang write FLang;
    property params : TParseMap read FParams write FParams;
    property indexer : TFhirIndexManager read FIndexer write SetIndexer;
    property repository : TFHIRDataStore read FRepository write SetRepository;
    property session : TFhirSession read FSession write SetSession;


    // outbound
    property link_ : String read FLink write FLink;
    property sort : String read FSort write FSort;
    property filter : String read FFilter write FFilter;
    property wantSummary : TFHIRSearchSummary read FWantSummary write FWantSummary;
  end;


implementation



{ TSearchProcessor }

procedure TSearchProcessor.Build;
var
  first : boolean;
  handled : boolean;
  i, j : integer;
  ix : TFhirIndex;
  ts : TStringList;
begin
  if typekey = 0 then
    filter := 'Ids.MasterResourceKey is null'
  else
    filter := 'Ids.MasterResourceKey is null and Ids.ResourceTypeKey = '+inttostr(typekey);

  if (compartmentId <> '') then
    filter := filter +' and Ids.ResourceKey in (select ResourceKey from Compartments where CompartmentType = 1 and Id = '''+compartmentId+''')';

  if (compartments <> '') then
    filter := filter +' and Ids.ResourceKey in (select ResourceKey from Compartments where CompartmentType = 1 and Id in ('+compartments+'))';

  link_ := '';
  first := false;
  ts := TStringList.create;
  try
    for i := 0 to params.Count - 1 do
    begin
      ts.Clear;
      ts.assign(params.List(i));
      for j := ts.count - 1 downto 0 do
        if ts[j] = '' then
          ts.delete(j);
      for j := 0 to ts.count - 1 do
      begin
        handled := false;
        filter := filter + processParam([type_], params.VarName(i), ts[j], false, first, handled);
        if handled then
          link_ := link_ + '&'+params.VarName(i)+'='+EncodeMIME(ts[j]);
      end;
    end;
  finally
    ts.free;
  end;

  if params.VarExists(SEARCH_PARAM_NAME_SORT) and (params.Value[SEARCH_PARAM_NAME_SORT] <> '_id') then
  begin
    ix := FIndexer.Indexes.getByName(type_, params.Value[SEARCH_PARAM_NAME_SORT]);
    if (ix = nil) then
      Raise Exception.create(StringFormat(GetFhirMessage('MSG_SORT_UNKNOWN', lang), [params.Value[SEARCH_PARAM_NAME_SORT]]));
    sort :='(SELECT Min(Value) FROM IndexEntries WHERE IndexEntries.ResourceKey = Ids.ResourceKey and IndexKey = '+inttostr(ix.Key)+')';
    link_ := link_+'&'+SEARCH_PARAM_NAME_SORT+'='+ix.Name;
  end
  else
  begin
    sort := 'Id';
    link_ := link_+'&'+SEARCH_PARAM_NAME_SORT+'=_id';
  end;
end;

function TSearchProcessor.buildParameterReference(index: Integer; n: Char; j: string; name : String; op : TFSCompareOperation; value: string) : String;
var
  parts: TArray<String>;
begin
  case op of
    fscoEQ:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value = ''' + SQLWrapString(Value) + '''' + j + ')';
    fscoNE:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value <> ''' + SQLWrapString(Value) + '''' + j + ')';
    fscoCO:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value2 like ''%' + SQLWrapString(Value) + '%''' + j + ')';
    fscoSW:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value2 like ''' + SQLWrapString(Value) + '%''' + j + ')';
    fscoEW:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value2 like ''%' + SQLWrapString(Value) + '''' + j + ')';
    fscoRE:
      begin
        if value.StartsWith(baseURL) then
          value := value.Substring(baseURL.Length);
        if value.StartsWith('http:') or value.StartsWith('http:') then
          // external reference - treat as equals
          result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value = ''' + SQLWrapString(value) + '''' + j + ')'
        else
        begin
          parts := value.Split(['/']);
          if length(parts) = 1 then
            result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value = ''' + SQLWrapString(value) + '''' + j + ')'
          else
            result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.SpaceKey = (Select SpaceKey from Spaces where Space = ''' + sqlwrapstring(parts[0]) + ''') and ' + n + '.Value = ''' + SQLWrapString(parts[1]) + '''' + j + ')';
        end;
      end;
  else
    //
    raise Exception.Create('The operation ''' + CODES_CompareOperation[op] + ''' is not supported for parameter types of reference');
  end;
end;

function TSearchProcessor.buildParameterToken(index: Integer; n: Char; j: string; name : String; op : TFSCompareOperation; value: string) : String;
var
  ref: string;
  like: Boolean;
begin
  begin
    like := false;
    if value.Contains('|') then
    begin
      StringSplit(value, '|', ref, value);
      if (ref = '') then
        ref := n + '.SpaceKey is null and '
      else if (ref = 'loinc') then
        ref := n + '.SpaceKey = (Select SpaceKey from Spaces where Space = ''http://loinc.org'') and '
      else if (ref = 'snomed') then
        ref := n + '.SpaceKey = (Select SpaceKey from Spaces where Space = ''http://snomed.info/sct'') and '
      else if (ref = 'rxnorm') then
        ref := n + '.SpaceKey = (Select SpaceKey from Spaces where Space = ''http://www.nlm.nih.gov/research/umls/rxnorm'') and '
      else if (ref = 'ucum') then
        ref := n + '.SpaceKey = (Select SpaceKey from Spaces where Space = ''http://unitsofmeasure.org'') and '
      else
        ref := n + '.SpaceKey = (Select SpaceKey from Spaces where Space = ''' + sqlwrapstring(ref) + ''') and ';
    end
    else
      ref := '';
    like := (Name = '_language');
    case op of
      fscoEQ:
        if like then
          result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' /*' + name + '*/ and ' + ref + ' ' + n + '.Value like ''' + sqlwrapString(value) + '''%)'
        else
          result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' /*' + Name + '*/ and ' + ref + ' ' + n + '.Value = ''' + sqlwrapString(value) + ''')';
      fscoNE:
        if like then
          result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' /*' + name + '*/ and ' + ref + ' ' + n + '.Value <> ''' + sqlwrapString(value) + ''')'
        else
          result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' /*' + name + '*/ and ' + ref + ' not (' + n + '.Value like ''' + sqlwrapString(value) + '''%))';
      fscoSS:
        raise Exception.Create('Not implemented yet');
      fscoSB:
        raise Exception.Create('Not implemented yet');
      fscoIN:
        raise Exception.Create('Not implemented yet');
      fscoCO:
        result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value2 like ''%' + SQLWrapString(value) + '%''' + j + ')';
      fscoSW:
        result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value2 like ''' + SQLWrapString(value) + '%''' + j + ')';
      fscoEW:
        result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value2 like ''%' + SQLWrapString(value) + '''' + j + ')';
    else
      // fscoGT, fscoLT, fscoGE, fscoLE, fscoPO, fscoRE
      raise Exception.Create('The operation ''' + CODES_CompareOperation[op] + ''' is not supported for parameter types of token');
    end;
  end;
end;

function TSearchProcessor.buildParameterDate(index: Integer; n: Char; j: string; name : String; op : TFSCompareOperation; value: string) : String;
var
  date: TDateAndTime;
begin
  begin
    date := TDateAndTime.CreateXML(value);
    try
      case op of
        fscoEQ:
          result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value = ''' + date.AsUTCDateTimeMinHL7 + ''' and ' + n + '.Value2 = ''' + date.AsUTCDateTimeMaxHL7 + '''' + j + ')';
        fscoNE:
          result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and (' + n + '.Value <> ''' + date.AsUTCDateTimeMinHL7 + ''' or ' + n + '.Value2 <> ''' + date.AsUTCDateTimeMaxHL7 + ''')' + j + ')';
        fscoGT:
          result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value2 >= ''' + date.AsUTCDateTimeMaxHL7 + '''' + j + ')';
        fscoLT:
          result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value <= ''' + date.AsUTCDateTimeMinHL7 + '''' + j + ')';
        fscoGE:
          result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value2 >= ''' + date.AsUTCDateTimeMinHL7 + '''' + j + ')';
        fscoLE:
          result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value <= ''' + date.AsUTCDateTimeMaxHL7 + '''' + j + ')';
        fscoPO:
          result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and (' + n + '.Value >= ''' + date.AsUTCDateTimeMaxHL7 + ''' or ' + n + '.Value2 <= ''' + date.AsUTCDateTimeMinHL7 + ''')' + j + ')';
      else
        // fscoSS, fscoSB, fscoIN, fscoRE, fscoCO, fscoSW, fscoEW
        raise Exception.Create('The operation ''' + CODES_CompareOperation[op] + ''' is not supported for parameter types of date');
      end;
    finally
      date.free;
    end;
  end;
end;

function TSearchProcessor.BuildParameterString(index: Integer; n: Char; j: string; name : String; op : TFSCompareOperation; value: string) : String;
begin
  case op of
    fscoEQ:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value = ''' + SQLWrapString(Value) + '''' + j + ')';
    fscoNE:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value <> ''' + SQLWrapString(Value) + '''' + j + ')';
    fscoCO:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value like ''%' + SQLWrapString(Value) + '%''' + j + ')';
    fscoSW:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value like ''' + SQLWrapString(Value) + '%''' + j + ')';
    fscoEW:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value like ''%' + SQLWrapString(Value) + '''' + j + ')';
    fscoGT:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value > ''' + SQLWrapString(Value) + '''' + j + ')';
    fscoLT:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value < ''' + SQLWrapString(Value) + '''' + j + ')';
    fscoGE:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value >= ''' + SQLWrapString(Value) + '''' + j + ')';
    fscoLE:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and ' + n + '.Value <= ''' + SQLWrapString(Value) + '''' + j + ')';
  else
    // fscoPO, fscoSS, fscoSB, fscoIN, fscoRE
    raise Exception.Create('The operation ''' + CODES_CompareOperation[op] + ''' is not supported for parameter types of string');
  end;
end;

function TSearchProcessor.BuildParameterNumber(index: Integer; n: Char; j: string; name : String; op : TFSCompareOperation; value: string) : String;
  function CheckInteger(s : String):String;
  begin
    if StringIsInteger32(s) then
      result := s
    else
      raise Exception.Create('not a valid number');
  end;
begin
  case op of
    fscoEQ:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and Cast(' + n + '.Value as int) = ' + CheckInteger(Value) + j + ')';
    fscoNE:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and Cast(' + n + '.Value as int) <> ' + CheckInteger(Value) + j + ')';
    fscoGT:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and Cast(' + n + '.Value as int) > ' + CheckInteger(Value) + j + ')';
    fscoLT:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and Cast(' + n + '.Value as int) < ' + CheckInteger(Value) + j + ')';
    fscoGE:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and Cast(' + n + '.Value as int) >= ' + CheckInteger(Value) + j + ')';
    fscoLE:
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index) + ' and Cast(' + n + '.Value as int) <= ' + CheckInteger(Value) + j + ')';
  else
    // fscoCO, fscoSW, fscoEW, fscoPO, fscoSS, fscoSB, fscoIN, fscoRE
    raise Exception.Create('The operation ''' + CODES_CompareOperation[op] + ''' is not supported for parameter types of number');
  end;
end;


procedure TSearchProcessor.processQuantityValue(name, lang : String; parts : TArray<string>; op : TQuantityOperation; var minv, maxv, space, mincv, maxcv, spaceC : String);
var
  dec : TSmartDecimalContext;
  value : TSmartDecimal;
  ns, s : String;
  specified, canonical : TUcumPair;
  v, u : String;
  i : integer;
begin
  minv := '';
  maxv := '';
  space := '';
  mincv := '';
  maxcv := '';
  spaceC := '';

  // [number]|[namespace]|[code]
  if Length(parts) = 0 then
    raise exception.create(StringFormat(GetFhirMessage('MSG_PARAM_UNKNOWN', lang), [name]));
  if TSmartDecimal.StringIsValid(parts[0]) then
    v := parts[0]
  else
  begin
    i := 1;
    s := parts[0];
    while (i <= length(s)) and CharInSet(s[i], ['0'..'9', '.', '-']) do
      inc(i);
    if i = 1 then
      raise exception.create(StringFormat(GetFhirMessage('MSG_PARAM_UNKNOWN', lang), [name]));
    v := parts[0].Substring(0, i-1);
    u := parts[0].Substring(i-1);
  end;
  dec := TSmartDecimalContext.Create;
  try
    value := dec.Value(v);

    // work out the numerical limits
    case op of
      qopEqual :
        begin
        minv := normaliseDecimal(value.lowerBound.AsDecimal);
        maxv := normaliseDecimal(value.upperBound.AsDecimal);
        end;
      qopLess :
        maxv := normaliseDecimal(value.lowerBound.AsDecimal);
      qopLessEqual :
        maxv := normaliseDecimal(value.immediateLowerBound.AsDecimal);
      qopGreater :
        minv := normaliseDecimal(value.UpperBound.AsDecimal);
      qopGreaterEqual :
        minv := normaliseDecimal(value.immediateUpperBound.AsDecimal);
      qopApproximate :
        begin
        if value.IsNegative then
        begin
          minv := normaliseDecimal(value.Multiply(dec.Value('1.2')).lowerBound.AsDecimal);
          maxv := normaliseDecimal(value.Multiply(dec.Value('0.8')).upperBound.AsDecimal);
        end
        else
        begin
          minv := normaliseDecimal(value.Multiply(dec.Value('0.8')).lowerBound.AsDecimal);
          maxv := normaliseDecimal(value.Multiply(dec.Value('1.2')).upperBound.AsDecimal);
        end;
        end;
    end;

    if (length(parts) = 1) then
      space := u
    else if length(parts) = 2 then
    begin
      if u = '' then
        space := parts[1]
      else
      begin
        space := u;
        ns := parts[1];
      end;
    end
    else if (length(parts) > 3) or (u <> '') then
      raise exception.create(StringFormat(GetFhirMessage('MSG_PARAM_UNKNOWN', lang), [name]))
    else
    begin
      if (parts[2] = 'ucum') or (parts[2] = 'snomed') or (parts[2].StartsWith('http:')) then
      begin
        // 2 is namespace
        space := parts[1];
        ns := parts[2];
      end
      else if (parts[1] = 'ucum') or (parts[1] = 'snomed') or (parts[1].StartsWith('http:')) then
      begin
        // 1 is namespace (per spec)
        space := parts[2];
        ns := parts[1];
      end;
    end;

    if (ns = 'ucum') then
      ns := 'http://unitsofmeasure.org'
    else if ns  = 'snomed' then
      ns := 'http://snomed.info/sct';

    if (ns = 'http://unitsofmeasure.org') then
    begin
      specified := TUcumPair.create;
      try
        specified.Value := value.Link;
        specified.UnitCode := space;
        canonical := repository.TerminologyServer.Ucum.getCanonicalForm(specified);
        try
          mincv := normaliseDecimal(canonical.Value.lowerBound.AsDecimal);
          maxcv := normaliseDecimal(canonical.Value.upperBound.AsDecimal);
          spaceC := 'urn:ucum-canonical#'+canonical.UnitCode;
        finally
          canonical.free;
        end;
      finally
        specified.free;
      end;
    end;

    if (ns <> '') then
      space := ns+'#'+space;
  finally
    dec.Free;
  end;
end;

function lt(name, value : String) :String;
begin
  if value.StartsWith('-') then
    result := '(Left('+name+', 1) = ''-'' and '+name+' > '''+value+''')'
  else
    result := name+' < '''+value+'''';
end;

function gt(name, value : String) :String;
begin
  if value.StartsWith('-') then
    result := '((Left('+name+', 1) = ''-'' and '+name+' < '''+value+''')) or ((Left('+name+', 1) <> ''-'' and '+name+' > '''+value+'''))'
  else
    result := name+' > '''+value+'''';
end;

function lte(name, value : String) :String;
begin
  if value.StartsWith('-') then
    result := '(Left('+name+', 1) = ''-'' and '+name+' >= '''+value+''')'
  else
    result := name+' <= '''+value+'''';
end;

function gte(name, value : String) :String;
begin
  if value.StartsWith('-') then
    result := '((Left('+name+', 1) = ''-'' and '+name+' <= '''+value+''')) or ((Left('+name+', 1) <> ''-'' and '+name+' > '''+value+'''))'
  else
    result := name+' >= '''+value+'''';
end;

function TypeForName(name : String) : integer;
begin
  if (name = '_profile') then
    result := ord(tkProfile)
  else if (name = '_tag') then
    result := ord(tkTag)
  else if (name = '_security') then
    result := ord(tkSecurity)
  else
    result := 0;
end;

function KindForName(name : String) : TFhirTagKind;
begin
  if (name = '_profile') then
    result := tkProfile
  else if (name = '_tag') then
    result := tkTag
  else if (name = '_security') then
    result := tkSecurity
  else
    result := tkUnknown;
end;

Function TSearchProcessor.filterTypes(types : TFHIRResourceTypeSet) : TFHIRResourceTypeSet;
var
  a : TFHIRResourceType;
begin
  result := [];
  for a in types do
    if session.canRead(a) then
      result := result + [a];
end;

Function TSearchProcessor.processParam(types : TFHIRResourceTypeSet; name : String; value : String; nested : boolean; var bFirst : Boolean; var bHandled : Boolean) : String;
var
  key, i : integer;
  left, right, op, modifier, v1,v2, v1c, v2c, sp, spC, tl : String;
  f : Boolean;
  ts : TStringList;
  pfx, sfx : String;
  date : TDateAndTime;
  a : TFHIRResourceType;
  type_ : TFhirSearchParamType;
  parts : TArray<string>;
  dop : TDateOperation;
  qop : TQuantityOperation;
begin
  a := frtNull;
  date := nil;
  result := '';
  op := '';
  bHandled := false;
  if (value = '') then
    exit;

  if (name = '_include') or (name = '_reverseInclude') then
    bHandled := true
  else if (name = '_summary') and (value = 'true') then
  begin
    bHandled := true;
    wantSummary := ssSummary;
  end
  else if (name = '_filter') and not nested then
  begin
    bHandled := true;
    result:= processSearchFilter(value);
  end
  else if (name = '_summary') and (value = 'text') then
  begin
    bHandled := true;
    wantSummary := ssText;
  end
  else if (name = '_text') then
  begin
    result := '(IndexKey = '+inttostr(FIndexer.NarrativeIndex)+' and CONTAINS(Xhtml, '''+SQLWrapString(value)+'''))';
  end
  else if pos('.', name) > 0 then
  begin
    StringSplit(name, '.', left, right);
    if (pos(':', left) > 0) then
    begin
      StringSplit(left, ':', left, modifier);
      if not StringArrayExistsInSensitive(CODES_TFHIRResourceType, modifier) then
        raise Exception.create(StringFormat(GetFhirMessage('MSG_UNKNOWN_TYPE', lang), [modifier]));
      a := TFHIRResourceType(StringArrayIndexOfInSensitive(CODES_TFHIRResourceType, modifier));
      types := filterTypes([a]);
    end
    else
    begin
      types := filterTypes(FIndexer.GetTargetsByName(types, left));
    end;
    key := FIndexer.GetKeyByName(types, left);
    if key = 0 then
      raise Exception.create(StringFormat(GetFhirMessage('MSG_PARAM_CHAINED', lang), [left]));
    f := true;
    tl := '';
    for a in types do
      tl := tl+','+inttostr(FRepository.ResConfig[a].key);
    if (tl <> '') then
      tl := tl.Substring(1);
    if (tl = '') then
    begin
      result := ''; // cannot match because the chain cannot be executed
      bHandled := false;
    end
    else
    begin
      result := result + '(IndexKey = '+inttostr(Key)+' /*'+left+'*/ and target in (select ResourceKey from IndexEntries where (ResourceKey in '+
        '(select ResourceKey from Ids where ResourceTypeKey in ('+tl+')) and ('+processParam(types, right, lowercase(value), true, f, bHandled)+'))))';
      bHandled := true;
    end;
  end
  else
  begin
    //remove the modifier:
    if (pos(':', name) > 0) then
      StringSplit(name, ':', name, modifier);

    if name = 'originalId' then
    begin
      bHandled := true;
      if modifier <> '' then
        raise exception.create('modifier "'+modifier+'" not handled on originalId');
      result :=  '(originalId = '''+sqlwrapString(value)+''')';
    end
    else
    begin
      key := FIndexer.GetKeyByName(types, name);
      if key > 0 then
      begin
        type_ := FIndexer.GetTypeByName(types, name);
        if modifier = 'missing' then
        begin
          bHandled := true;
          if StrToBoolDef(value, false) then
            result := result + '((Select count(*) from IndexEntries where IndexKey = '+inttostr(Key)+' /*'+name+'*/ and IndexEntries.ResourceKey = Ids.ResourceKey) = 0)'
          else
            result := result + '((Select count(*) from IndexEntries where IndexKey = '+inttostr(Key)+' /*'+name+'*/ and IndexEntries.ResourceKey = Ids.ResourceKey) > 0)';
        end
        else
        begin
          ts := TStringlist.create;
          try
            SplitByCommas(value, ts);
            if (ts.count > 1) then
              result := '(';
            for i := 0 to ts.count - 1 do
            begin
              if i > 0 then
                result := result +') or (';
              value := ts[i];
              if i > 0 then
                result := result + op;
              bHandled := true;
              case type_ of
                SearchParamTypeDate:
                  begin
                    if modifier <> '' then
                      raise exception.create(StringFormat(GetFhirMessage('MSG_PARAM_UNKNOWN', lang), [name+':'+modifier]));
                    dop := dopEqual;
                    if findPrefix(value, '<=') then
                      dop := dopLessEqual
                    else if findPrefix(value, '<') then
                      dop := dopLess
                    else if findPrefix(value, '>=') then
                      dop := dopGreaterEqual
                    else if findPrefix(value, '>') then
                      dop := dopGreater;
                    CheckDateFormat(value);
                    date := TDateAndTime.CreateXML(value);
                    try
                      case dop of
                        dopEqual:        result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and Value >= '''+date.AsUTCDateTimeMinHL7+''' and Value2 <= '''+date.AsUTCDateTimeMaxHL7+''')';
                        dopLess:         result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and Value <= '''+date.AsUTCDateTimeMinHL7+''')';
                        dopLessEqual:    result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and Value <= '''+date.AsUTCDateTimeMaxHL7+''')';
                        dopGreater:      result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and Value2 >= '''+date.AsUTCDateTimeMaxHL7+''')';
                        dopGreaterEqual: result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and Value2 >= '''+date.AsUTCDateTimeMinHL7+''')';
                      end;
                    finally
                      date.free;
                      date := nil;
                    end;
                  end;
                SearchParamTypeString:
                  begin
                    value := lowercase(value);
                    if name = 'phonetic' then
                      value := EncodeNYSIIS(value);
                    if (modifier = 'partial') or (modifier = '') then
                    begin
                      pfx := 'like ''%';
                      sfx := '%''';
                    end
                    else if (modifier = 'exact') then
                    begin
                      pfx := '= ''';
                      sfx := '''';
                    end
                    else
                      raise exception.create(StringFormat(GetFhirMessage('MSG_PARAM_UNKNOWN', lang), [modifier]));
                    result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and Value '+pfx+sqlwrapString(lowercase(RemoveAccents(value)))+sfx+')';
                  end;
                SearchParamTypeUri:
                  begin
                    value := lowercase(value);
                    if (modifier = 'partial') or (modifier = '') then
                    begin
                      pfx := 'like ''';
                      sfx := '%''';
                    end
                    else if (modifier = 'exact') then
                    begin
                      pfx := '= ''';
                      sfx := '''';
                    end
                    else
                      raise exception.create(StringFormat(GetFhirMessage('MSG_PARAM_UNKNOWN', lang), [modifier]));
                    result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and Value '+pfx+sqlwrapString(lowercase(RemoveAccents(value)))+sfx+')';
                  end;
                SearchParamTypeToken:
                  begin
                  value := lowercase(value);
                  // _id is a special case
                  if (name = '_id') or (name = 'id') then
                    result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and Value = '''+sqlwrapString(value)+''')'
                  else if (name = '_language') then
                    result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and Value like '''+sqlwrapString(value)+'%'')'
                  else if modifier = 'text' then
                    result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and Value2 like '''+sqlwrapString(lowercase(RemoveAccents(value)))+'%'')'
                  else if modifier = 'in' then
                    result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and '+processValueSetMembership(value)+')'
                  else if value.Contains('|') then
                  begin
                    StringSplit(value, '|', left, right);
                    if (right = '') then
                      result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and SpaceKey = (Select SpaceKey from Spaces where Space = '''+sqlwrapstring(left)+'''))'
                    else
                      result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and SpaceKey = (Select SpaceKey from Spaces where Space = '''+sqlwrapstring(left)+''') and Value = '''+sqlwrapString(right)+''')';
                  end
                  else
                    result :=  result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and Value = '''+sqlwrapString(value)+''')'
                  end;
                SearchParamTypeReference :
                  begin
                  // _id is a special case
                  if (name = '_id') or (name = 'id') or (FIndexer.GetTypeByName(types, name) = SearchParamTypeToken) then
                    result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and Value = '''+sqlwrapString(value)+''')'
                  else if modifier = 'text' then
                    result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and Value2 like '''+sqlwrapString(lowercase(RemoveAccents(value)))+'%'')'
                  else if (modifier = 'anyns') or (modifier = '') then
                  begin
                    if IsId(value) then
                      result :=  result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and Value = '''+sqlwrapString(value)+''')'
                    else if value.StartsWith(baseUrl) then
                    begin
                      parts := value.Substring(baseURL.Length).Split(['/']);
                      if Length(parts) = 2 then
                      begin
                        result :=  result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and SpaceKey = (Select SpaceKey from Spaces where Space = '''+sqlwrapstring(parts[0])+''')  and Value = '''+sqlwrapString(parts[1])+''')'
                      end
                      else
                        raise exception.create(StringFormat(GetFhirMessage('MSG_PARAM_UNKNOWN', lang), [name]))
                    end
                    else
                      raise exception.create(StringFormat(GetFhirMessage('MSG_PARAM_UNKNOWN', lang), [modifier]))
                  end
                  else
                  begin
                    if IsId(value) then
                      result :=  result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and SpaceKey = (Select SpaceKey from Spaces where Space = '''+sqlwrapstring(modifier)+''') and Value = '''+sqlwrapString(value)+''')'
                    else if value.StartsWith(baseUrl) then
                    begin
                      parts := value.Substring(baseURL.Length).Split(['/']);
                      if Length(parts) = 2 then
                      begin
                        result :=  result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and SpaceKey = (Select SpaceKey from Spaces where Space = '''+sqlwrapstring(parts[0])+''') and SpaceKey = (Select SpaceKey from Spaces where Space = '''+sqlwrapstring(modifier)+''')  and Value = '''+sqlwrapString(parts[1])+''')'
                      end
                      else
                        raise exception.create(StringFormat(GetFhirMessage('MSG_PARAM_UNKNOWN', lang), [name]))
                    end
                    else
                      raise exception.create(StringFormat(GetFhirMessage('MSG_PARAM_UNKNOWN', lang), [modifier]))
                  end
                  end;
                SearchParamTypeQuantity :
                  begin
                    if modifier <> '' then
                      raise exception.create(StringFormat(GetFhirMessage('MSG_PARAM_UNKNOWN', lang), [name+':'+modifier]));
                    qop := qopEqual;
                    if findPrefix(value, '<=') then
                      qop := qopLessEqual
                    else if findPrefix(value, '<') then
                      qop := qopLess
                    else if findPrefix(value, '>=') then
                      qop := qopGreaterEqual
                    else if findPrefix(value, '>') then
                      qop := qopGreater
                    else if findPrefix(value, '~') then
                      qop := qopApproximate;
                    processQuantityValue(name, lang, value.Split(['|']), qop, v1, v2, sp, v1C, v2C, spC);
                    if spc <> '' then
                    begin
                      case qop of
                        qopEqual:        result := result
                           + '((IndexKey = '+inttostr(Key)+' /*'+name+'*/ and flag = 0 and SpaceKey = (Select SpaceKey from Spaces where Space = '''+sqlwrapstring(sp)+''') and '+gte('Value', v1)+' and '+lte('Value2', v2)+') or '
                           + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and flag = 1 and SpaceKey = (Select SpaceKey from Spaces where Space = '''+sqlwrapstring(spC)+''') and '+gte('Value', v1C)+' and '+lte('Value2', v2C)+'))';
                        qopLess:         result := result
                           + '((IndexKey = '+inttostr(Key)+' /*'+name+'*/ and flag = 0 and SpaceKey = (Select SpaceKey from Spaces where Space = '''+sqlwrapstring(sp)+''') and '+lt('Value', v2)+') or '
                           + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and flag = 1 and SpaceKey = (Select SpaceKey from Spaces where Space = '''+sqlwrapstring(spC)+''') and '+lt('Value', v2C)+'))';
                        qopLessEqual:    result := result
                           + '((IndexKey = '+inttostr(Key)+' /*'+name+'*/ and flag = 0 and SpaceKey = (Select SpaceKey from Spaces where Space = '''+sqlwrapstring(sp)+''') and '+lt('Value', v2)+') or '
                           + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and flag = 1 and SpaceKey = (Select SpaceKey from Spaces where Space = '''+sqlwrapstring(spC)+''') and '+lt('Value', v2C)+'))';
                        qopGreater:      result := result
                           + '((IndexKey = '+inttostr(Key)+' /*'+name+'*/ and flag = 0 and SpaceKey = (Select SpaceKey from Spaces where Space = '''+sqlwrapstring(sp)+''') and '+gt('Value2', v1)+') or '
                           + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and flag = 1 and SpaceKey = (Select SpaceKey from Spaces where Space = '''+sqlwrapstring(spC)+''') and '+gt('Value2', v1C)+'))';
                        qopGreaterEqual: result := result
                           + '((IndexKey = '+inttostr(Key)+' /*'+name+'*/ and flag = 0 and SpaceKey = (Select SpaceKey from Spaces where Space = '''+sqlwrapstring(sp)+''') and '+gte('Value2', v1)+') or '
                           + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and flag = 1 and SpaceKey = (Select SpaceKey from Spaces where Space = '''+sqlwrapstring(spC)+''') and '+gte('Value2', v1C)+'))';
                        qopApproximate:  result := result
                           + '((IndexKey = '+inttostr(Key)+' /*'+name+'*/ and flag = 0 and SpaceKey = (Select SpaceKey from Spaces where Space = '''+sqlwrapstring(sp)+''') and '+gt('Value', v1)+' and '+lt('Value2', v2)+') or '
                           + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and flag = 1 and SpaceKey = (Select SpaceKey from Spaces where Space = '''+sqlwrapstring(spC)+''') and '+gt('Value', v1C)+' and '+lt('Value2', v2C)+'))';
                      end;
                    end
                    else
                    begin
                      if sp <> '' then
                        sp := 'and SpaceKey = (Select SpaceKey from Spaces where Space = '''+sqlwrapstring(sp)+''') ';
                      case qop of
                        qopEqual:        result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and flag = 0 '+sp+'and '+gte('Value', v1)+' and '+lte('Value2', v2)+')';
                        qopLess:         result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and flag = 0 '+sp+'and '+lt('Value', v2)+')';
                        qopLessEqual:    result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and flag = 0 '+sp+'and '+lt('Value', v2)+')';
                        qopGreater:      result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and flag = 0 '+sp+'and '+gt('Value2', v1)+')';
                        qopGreaterEqual: result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and flag = 0 '+sp+'and '+gte('Value2', v1)+')';
                        qopApproximate:  result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and flag = 0 '+sp+'and '+gt('Value', v1)+' and '+lt('Value2', v2)+')';
                      end;
                    end;
                  end;
              else if type_ <> SearchParamTypeNull then
                raise exception.create('not done yet: type = '+CODES_TFhirSearchParamType[type_]);
              end;
      {
      todo: renable for quantity with right words etc + ucum
              else if (right = 'before') or (right = 'after') then
              begin
                bHandled := true;
                if (right = 'before') then
                  op := '<='
                else if (right = 'after') then
                  op := '>='
                else
                  op := '=';
                result := result + '(IndexKey = '+inttostr(Key)+' /*'+name+'*/ and Value '+op+' '''+sqlwrapString(value)+''')';
              end
      }
            end;
          if ts.count > 1 then
            result := result + ')';
          finally
            ts.free;
          end;
        end;
      end;
    end;
  end;

  if result <> '' then
  begin
    if not nested and (name <> 'tag') then
      result := 'Ids.ResourceKey in (select ResourceKey from IndexEntries where '+result+')';
    if not bfirst then
      result := ' and '+result;
  end;
  bfirst := bfirst and (result = '');
end;



function TSearchProcessor.ProcessSearchFilter(value: String): String;
var
  filter : TFSFilter;
  issuer : TFSCharIssuer;
begin
  issuer := TFSCharIssuer.Create;
  try
    filter := TFSFilterParser.parse(value);
    try
      result := '('+BuildFilter(filter, ' ', issuer, [FType])+')';
    finally
      filter.Free;
    end;
  finally
    issuer.Free;
  end;
end;

function TSearchProcessor.processValueSetMembership(vs: String): String;
var
  vso : TFHIRValueSet;
begin
  // firstly, the vs can be a logical reference or a literal reference
  if (vs.StartsWith('valueset/')) then
  begin
    vso := FRepository.TerminologyServer.getValueSetByUrl(vs);
    try
      if vso = nil then
        vs := 'not-found'
      else
        vs := vso.url;
    finally
      vso.Free;
    end;
  end;
  result := 'Concept in (select ConceptKey from ValueSetMembers where ValueSetKey in (select ValueSetKey from ValueSets where URL = '''+sqlWrapString(vs)+'''))';
end;

procedure TSearchProcessor.replaceNames(paramPath: TFSFilterParameterPath; components: TDictionary<String, String>);
begin
  if components.ContainsKey(paramPath.Name) then
    paramPath.Name := components[paramPath.Name]
  else
    raise Exception.Create('Unknown Search Parameter Name "'+paramPath.Name+'"');
end;

procedure TSearchProcessor.replaceNames(filter: TFSFilter; components: TDictionary<String, String>);
begin
  if (filter = nil) then
    exit
  else if filter.FilterItemType = fsitLogical then
  begin
    replaceNames(TFSFilterLogical(filter).Filter1, components);
    replaceNames(TFSFilterLogical(filter).Filter2, components);
  end
  else
    replaceNames(TFSFilterParameter(filter).ParamPath, components);
end;

procedure TSearchProcessor.SetIndexer(const Value: TFhirIndexManager);
begin
  FIndexer := Value;
end;

procedure TSearchProcessor.SetRepository(const Value: TFHIRDataStore);
begin
  FRepository.Free;
  FRepository := Value;
end;



procedure TSearchProcessor.SetSession(const Value: TFhirSession);
begin
  FSession.Free;
  FSession := Value;
end;

procedure TSearchProcessor.SplitByCommas(value : String; list : TStringList);
var
  s : String;
begin
  for s in value.Split([',']) do
    list.add(s);
end;

function TSearchProcessor.findPrefix(var value : String; subst : String) : boolean;
begin
  result := value.StartsWith(subst);
  if result then
    value := value.Substring(subst.Length);
end;

function TSearchProcessor.BuildFilter(filter: TFSFilter; parent: char; issuer: TFSCharIssuer; types : TFHIRResourceTypeSet): String;
begin
  case filter.FilterItemType of
    fsitParameter : result := BuildFilterParameter(filter as TFSFilterParameter, TFSFilterParameter(filter).ParamPath, parent, issuer, types);
    fsitLogical :   result := BuildFilterLogical(filter as TFSFilterLogical, parent, issuer, types);
  else
    raise Exception.Create('Unknown type');
  end;
end;

function TSearchProcessor.BuildFilterLogical(filter: TFSFilterLogical; parent: char; issuer: TFSCharIssuer; types : TFHIRResourceTypeSet): String;
begin
  if filter.Operation = fsloNot then
    result := '(Not '+BuildFilter(filter.Filter2, parent, issuer, types)+')'
  else if filter.Operation = fsloOr then
    result := '('+BuildFilter(filter.Filter1, parent, issuer, types)+' or '+BuildFilter(filter.Filter2, parent, issuer, types)+')'
  else // filter.Operation = fsloAnd
    result := '('+BuildFilter(filter.Filter1, parent, issuer, types)+' and '+BuildFilter(filter.Filter2, parent, issuer, types)+')';

end;


function TSearchProcessor.BuildFilterParameter(filter: TFSFilterParameter; path : TFSFilterParameterPath; parent: char; issuer: TFSCharIssuer; types : TFHIRResourceTypeSet): String;
var
  index : integer;
  n : char;
  j : string;
  stype : TFhirSearchParamType;
  comp : TFhirComposite;
begin
  n := issuer.next;
  if parent = ' ' then
    j := ''
  else
    j := ' and '+n+'.parent = '+parent+'.EntryKey';
  index := FIndexer.GetKeyByName(types, path.Name);

  if path.Next <> nil then
  begin
    comp := FIndexer.getComposite(types, path.Name, types);
    if (comp <> nil) then
    begin
      if (filter = nil) then
        raise Exception.Create('Parameter ("'+path.Name+'") is missing a filter - it is required');
      // first, scan the filter - there must be one - and rename them. They must match
      replaceNames(path.Filter, comp.Components);
      replaceNames(path.next, comp.components);
      result := 'ResourceKey in (select ResourceKey from IndexEntries as '+n+' where (indexKey = '''+inttostr(index)+''' and '+BuildFilter(path.Filter, n, issuer, types) +')'+j;
      // ok, that's the filter. Now we process the content
      result := result + ' and '+BuildFilterParameter(filter, path.Next, n, issuer, types);
      result := result +')';
    end
    else
    begin
      result := 'ResourceKey in (select ResourceKey from IndexEntries as ' + n + ' where ' + n + '.IndexKey = ' + inttostr(index);
      if path.filter <> nil then
        raise Exception.Create('Not handled yet');
     //   + ' and ' + n + '.SpaceKey = (Select SpaceKey from Spaces where Space = ''' + sqlwrapstring(parts[0]) + ''')'
    // result := result +'  and ' + n + '.target in ()' + j + ')';
      result := result + ' and '+n+'.target in (select ResourceKey from IndexEntries where ('+BuildFilterParameter(filter, path.Next, parent, issuer, FIndexer.GetTargetsByName(types, path.name))+')))'+j;
    end;
  end
  else
  begin
    // do we recognise the attribute path?
    assert(path.Filter = nil); // not allowed in the grammar
    stype := FIndexer.GetTypeByName(types, path.Name);

    if filter.Operation = fscoPR then
    begin
      if (filter.value = 'true') then
        result := 'ResourceKey in (select ResourceKey from IndexEntries as '+n+' where '+n+'.IndexKey = '+inttostr(index)+j+')'
      else
        result := 'not (ResourceKey in (select ResourceKey from IndexEntries as '+n+' where '+n+'.IndexKey = '+inttostr(index)+j+'))';
    end
    else case stype of
      SearchParamTypeNull:
        raise Exception.Create('The search type could not be determined');
      SearchParamTypeNumber:    result := BuildParameterNumber(index, n, j, path.Name, filter.Operation, filter.Value);
      SearchParamTypeString :   result := BuildParameterString(index, n, j, path.Name, filter.Operation, filter.Value);
      SearchParamTypeDate:      result := buildParameterDate(index, n, j, path.Name, filter.Operation, filter.Value);
      SearchParamTypeToken:     result := buildParameterToken(index, n, j, path.Name, filter.Operation, filter.Value);
      SearchParamTypeReference: result := buildParameterReference(index, n, j, path.Name, filter.Operation, filter.Value);
      SearchParamTypeComposite: raise Exception.Create('Composite indexes cannot the direct target of an operation criteria (except for operation "pr")');
      SearchParamTypeQuantity:  raise Exception.Create('Quantity searching is not handled yet');
    end;
  end;
end;

procedure TSearchProcessor.checkDateFormat(s: string);
var
  ok : boolean;
begin
  ok := false;
  if (length(s) = 4) and StringIsCardinal16(s) then
    ok := true
  else if (length(s) = 7) and (s[5] = '-') and
          StringIsCardinal16(copy(s, 1, 4)) and StringIsCardinal16(copy(s, 5, 2)) then
    ok := true
  else if (length(s) = 10) and (s[5] = '-') and (s[8] = '-') and
          StringIsCardinal16(copy(s, 1, 4)) and StringIsCardinal16(copy(s, 6, 2)) and StringIsCardinal16(copy(s, 9, 2)) then
    ok := true
  else if (length(s) > 11) and (s[5] = '-') and (s[8] = '-') and (s[11] = 'T') and
          StringIsCardinal16(copy(s, 1, 4)) and StringIsCardinal16(copy(s, 6, 2)) and StringIsCardinal16(copy(s, 9, 2)) then
  begin
    if (length(s) = 16) and (s[14] = ':') and StringIsCardinal16(copy(s, 12, 2)) and StringIsCardinal16(copy(s, 15, 2)) then
      ok := true
    else if (length(s) = 19) and (s[14] = ':') and (s[17] = ':') and
          StringIsCardinal16(copy(s, 12, 2)) and StringIsCardinal16(copy(s, 15, 2)) and StringIsCardinal16(copy(s, 18, 2)) then
      ok := true;
  end;
  if not ok then
    raise exception.create(StringFormat(GetFhirMessage('MSG_DATE_FORMAT', lang), [s]));
end;




destructor TSearchProcessor.Destroy;
begin
  FRepository.Free;
  FSession.Free;
  inherited;
end;

end.

