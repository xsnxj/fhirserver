unit ValueSetEditorVCLForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, VirtualTrees, Vcl.ComCtrls,
  Math, Clipbrd,
  FHIRTypes, FHIRComponents, FHIRResources, FHIRUtilities,
  ValueSetEditorCore, ValueSetEditorRegisterServerForm, Vcl.Menus, Vcl.Buttons,
  Vcl.ImgList, VirtualStringTreeComboBox, StringSupport, Vcl.Imaging.pngimage,
  Vcl.OleCtrls, SHDocVw, ServerChooser, Vcl.ToolWin, LookAheadUnit, ValueSetEditorAbout,
  ServerOperationForm, System.ImageList;

Const
  NAME_INFORMATION = 'Value Set Information';
  NAME_DEFINE = 'Code Defined By Value Set';
  NAME_IMPORT = 'Import Value Set';
  NAME_INCLUDE = 'Include Codes';
  NAME_EXCLUDE = 'Exclude Codes';
  NAME_EXPAND = 'Expansion';

  COLOUR_OK = clWhite;
  COLOUR_MANDATORY = $FFEEEE;
  COLOUR_ERROR = $EEEEFF;
  COLOUR_WARNING = $EEFFFF;
  COLOUR_HINT = $EEFFEE;

type
  TForm5 = class(TForm)
    pnlToolbar: TPanel;
    opnValueSet: TFileOpenDialog;
    PageControl1: TPageControl;
    tabInformation: TTabSheet;
    tabDefined: TTabSheet;
    tabComposition: TTabSheet;
    tabExpansion: TTabSheet;
    Panel6: TPanel;
    Label8: TLabel;
    edtPhone: TEdit;
    Panel8: TPanel;
    Label9: TLabel;
    Panel9: TPanel;
    Label10: TLabel;
    edtIdentifier: TEdit;
    Panel10: TPanel;
    Label11: TLabel;
    edtVersion: TEdit;
    Panel11: TPanel;
    Label12: TLabel;
    edtPublisher: TEdit;
    Panel12: TPanel;
    Label13: TLabel;
    edtCopyright: TEdit;
    Label14: TLabel;
    edtEmail: TEdit;
    Label15: TLabel;
    edtWeb: TEdit;
    Panel13: TPanel;
    Label16: TLabel;
    cbExperimental: TCheckBox;
    cbxStatus: TComboBox;
    Panel14: TPanel;
    Label17: TLabel;
    edtName: TEdit;
    tvDefines: TVirtualStringTree;
    Panel17: TPanel;
    Panel18: TPanel;
    Label18: TLabel;
    edtDefineVersion: TEdit;
    Panel19: TPanel;
    Label19: TLabel;
    edtDefineURI: TEdit;
    cbDefineCase: TCheckBox;
    Notebook2: TNotebook;
    Panel22: TPanel;
    Panel25: TPanel;
    Label20: TLabel;
    Panel23: TPanel;
    Panel26: TPanel;
    Panel24: TPanel;
    Label21: TLabel;
    Panel27: TPanel;
    Label22: TLabel;
    tvFilters: TVirtualStringTree;
    Panel28: TPanel;
    Label23: TLabel;
    tvCodes: TVirtualStringTree;
    Splitter2: TSplitter;
    Panel29: TPanel;
    Label24: TLabel;
    edtSystemRefVersion: TEdit;
    CheckBox1: TCheckBox;
    mnuSaveAs: TPopupMenu;
    File1: TMenuItem;
    OSer1: TMenuItem;
    svValueSet: TFileSaveDialog;
    oServerasExisting1: TMenuItem;
    pnlExpansion: TPanel;
    Button2: TButton;
    tvExpansion: TVirtualStringTree;
    lblExpansion: TLabel;
    Label26: TLabel;
    edtFilter: TEdit;
    tvPreview: TVirtualStringTree;
    MainMenu1: TMainMenu;
    File2: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    Print1: TMenuItem;
    PrintSetup1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    Edit1: TMenuItem;
    miUndo: TMenuItem;
    miRedo: TMenuItem;
    miCut: TMenuItem;
    miCopy: TMenuItem;
    miPaste: TMenuItem;
    PasteSpecial1: TMenuItem;
    Find1: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    Help1: TMenuItem;
    miDoco: TMenuItem;
    miWebPage: TMenuItem;
    miAbout: TMenuItem;
    ools1: TMenuItem;
    Import2: TMenuItem;
    Export1: TMenuItem;
    OpenFromServer1: TMenuItem;
    pnlDocumentation: TPanel;
    txtDescription: TMemo;
    imgEnabled: TImageList;
    ToolBar1: TToolBar;
    tbNew: TToolButton;
    tbOpenFile: TToolButton;
    tbOpenServer: TToolButton;
    tbSave: TToolButton;
    tbSaveAs: TToolButton;
    ToolButton6: TToolButton;
    tbUndo: TToolButton;
    tbRedo: TToolButton;
    ToolButton9: TToolButton;
    tbCut: TToolButton;
    tbCopy: TToolButton;
    tbPaste: TToolButton;
    ToolButton13: TToolButton;
    tbFind: TToolButton;
    ToolButton15: TToolButton;
    tbInsert: TToolButton;
    tbDelete: TToolButton;
    tbUp: TToolButton;
    tbDown: TToolButton;
    tbIn: TToolButton;
    tbOut: TToolButton;
    ToolButton22: TToolButton;
    tbImport: TToolButton;
    tbExport: TToolButton;
    ToolButton25: TToolButton;
    tbHelp: TToolButton;
    pmTreeView: TPopupMenu;
    miTvInsert: TMenuItem;
    miTvDelete: TMenuItem;
    miTvUp: TMenuItem;
    miTvDown: TMenuItem;
    miTvIn: TMenuItem;
    miTvOut: TMenuItem;
    edtSystemReference: TLookAheadEdit;
    edtImportUri: TLookAheadEdit;
    imgDisabled: TImageList;
    webDoco: TWebBrowser;
    WelcomeScreen1: TMenuItem;
    N3: TMenuItem;
    OpenfromUrl1: TMenuItem;
    Panel20: TPanel;
    Panel21: TPanel;
    tvStructure: TVirtualStringTree;
    Splitter1: TSplitter;
    Label1: TLabel;
    btnEditCodes: TButton;
    Label2: TLabel;
    btnNewImport: TButton;
    Label3: TLabel;
    btnNewInclude: TButton;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    btnNewExclude: TButton;
    Label25: TLabel;
    pmtvStructure: TPopupMenu;
    mnuStructureUp: TMenuItem;
    mnuStructureDown: TMenuItem;
    mnuStructureInsert: TMenuItem;
    mnuStructureDelete: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnOpenServerClick(Sender: TObject);
    procedure btnOpenFileClick(Sender: TObject);
    procedure tvStructureInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure tvStructureGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure tvStructureInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
    procedure tvStructurePaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
    procedure tvStructureClick(Sender: TObject);
    procedure tvDefinesColumnResize(Sender: TVTHeader; Column: TColumnIndex);
    procedure tvCodesColumnResize(Sender: TVTHeader; Column: TColumnIndex);
    procedure tvCodesInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure tvCodesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure tvCodesNewText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; NewText: string);
    procedure tvCodesCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure btnAddCodeClick(Sender: TObject);
    procedure btnDeleteCodeClick(Sender: TObject);
    procedure tvFiltersColumnResize(Sender: TVTHeader; Column: TColumnIndex);
    procedure tvDefinesInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure tvDefinesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure tvDefinesCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure GetAbstractList(context : string; list : TStrings);
    procedure btnAddDefineClick(Sender: TObject);
    procedure edtNameChange(Sender: TObject);
    procedure cbxStatusChange(Sender: TObject);
    procedure cbExperimentalClick(Sender: TObject);
    procedure edtIdentifierChange(Sender: TObject);
    procedure edtVersionChange(Sender: TObject);
    procedure edtPublisherChange(Sender: TObject);
    procedure edtCopyrightChange(Sender: TObject);
    procedure edtPhoneChange(Sender: TObject);
    procedure edtEmailChange(Sender: TObject);
    procedure edtWebChange(Sender: TObject);
    procedure txtDescriptionChange(Sender: TObject);
    procedure edtDefineURIChange(Sender: TObject);
    procedure edtDefineVersionChange(Sender: TObject);
    procedure tvDefinesNewText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; NewText: string);
    procedure btnDeleteDefineClick(Sender: TObject);
    procedure btnDefineUpClick(Sender: TObject);
    procedure btnDefineDownClick(Sender: TObject);
    procedure btnDefineRightClick(Sender: TObject);
    procedure btnDefineLeftClick(Sender: TObject);
    procedure tvDefinesInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
    procedure btnCodesUpClick(Sender: TObject);
    procedure btnCodesDownClick(Sender: TObject);
    procedure edtSystemReferenceChange(Sender: TObject);
    procedure edtSystemRefVersionChange(Sender: TObject);
    procedure tvFiltersGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure tvFiltersInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure tvFiltersCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure btnAddFilterClick(Sender: TObject);
    procedure btnDeleteFilterClick(Sender: TObject);
    procedure btnFiltersUpClick(Sender: TObject);
    procedure btnFiltersDownClick(Sender: TObject);
    procedure tvFiltersNewText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; NewText: string);
    procedure btnUndoClick(Sender: TObject);
    procedure btnRedoClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnSaveAsClick(Sender: TObject);
    procedure File1Click(Sender: TObject);
    procedure OSer1Click(Sender: TObject);
    procedure oServerasExisting1Click(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure tvExpansionColumnResize(Sender: TVTHeader; Column: TColumnIndex);
    procedure tvExpansionInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure tvExpansionGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure tvExpansionInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
    procedure tvExpansionCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure Button2Click(Sender: TObject);
    procedure edtFilterChange(Sender: TObject);
    procedure tvPreviewColumnResize(Sender: TVTHeader; Column: TColumnIndex);
    procedure tvPreviewCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure tvPreviewGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure tvPreviewInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
    procedure tvPreviewInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure edtImportUriChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure miDocoClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure miCutClick(Sender: TObject);
    procedure miCopyClick(Sender: TObject);
    procedure miPasteClick(Sender: TObject);
    procedure tvDefinesEnter(Sender: TObject);
    procedure tvDefinesExit(Sender: TObject);
    procedure tvDefinesFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
    procedure tvDefinesEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
    procedure tvDefinesEdited(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
    procedure tvDefinesEditCancelled(Sender: TBaseVirtualTree; Column: TColumnIndex);
    procedure pmTreeViewPopup(Sender: TObject);
    procedure tvCodesEnter(Sender: TObject);
    procedure tvCodesExit(Sender: TObject);
    procedure tvStructureFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
    procedure tvCodesFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
    procedure tvFiltersFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
    procedure tvFiltersEnter(Sender: TObject);
    procedure tvFiltersExit(Sender: TObject);
    procedure tvDefinesKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tvCodesKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tvFiltersKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tvAllGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle; var HintText: string);
    procedure tvAllGetHintKind(sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Kind: TVTHintKind);
    procedure edtSystemReferenceEnter(Sender: TObject);
    procedure edtImportUriEnter(Sender: TObject);
    procedure LocationChange(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure WelcomeScreen1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure OpenfromUrl1Click(Sender: TObject);
    procedure tvDefinesBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
    procedure tvCodesBeforeCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
    procedure tvCodesDrawText(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; const Text: string; const CellRect: TRect; var DefaultDraw: Boolean);
    procedure pmtvStructurePopup(Sender: TObject);
    procedure btnAddRuleClick(sender : TObject);
    procedure btnDeleteRuleClick(sender : TObject);
    procedure btnRuleUpClick(sender : TObject);
    procedure btnRuleDownClick(sender : TObject);
    procedure btnEditCodesClick(Sender: TObject);
    procedure btnNewImportClick(Sender: TObject);
    procedure btnNewIncludeClick(Sender: TObject);
    procedure btnNewExcludeClick(Sender: TObject);
  private
    { Private declarations }
    Context : TValueSetEditorContext;
    loading : boolean;
    activated : boolean;
    FOnCheckButtons : TNotifyEvent;
    FFirstChar : String;
    procedure LoadValuesetPage;
    procedure Refresh;
    procedure ContextStateChange(sender : TObject);
    procedure ShowPreview(sender : TObject);
    procedure SetDocoVisibility(visible : boolean);
    procedure Validate(sender : TObject);
    procedure ValidateCombo(combo : TCombobox; outcome : TValidationOutcome);
    procedure ValidateEdit(edit : TEdit; outcome : TValidationOutcome);
    procedure ValidateMemo(memo : TMemo; outcome : TValidationOutcome);
    procedure noButtons(sender  : TObject);
    procedure defineCheckButtons(sender : TObject);
    procedure codesCheckButtons(sender : TObject);
    procedure filtersCheckButtons(sender: TObject);
    procedure doco(filename : String);
    function EditValue(text : String):String;
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

{$R *.dfm}

uses ValueSetEditorWelcome;


// --- general -----------------------------------------------------------------

procedure TForm5.File1Click(Sender: TObject);
begin
  if svValueSet.Execute then
    Context.saveAsFile(svValueSet.FileName);
end;

procedure TForm5.FormActivate(Sender: TObject);
begin
  if not activated then
  begin
    activated := true;
    if not Context.Settings.HasViewedWelcomeScreen or (Context.Settings.ServerCount = 0) Or (Context.Settings.ServerURL = '') then
      WelcomeScreen1Click(self)
    else
    begin
      try
        ServerOperation(Context.SetNominatedServer, Context.Settings.ServerURL, 'Connecting to Server '+Context.Settings.ServerURL, false);
      Except
        on e : Exception do
        begin
          if MessageDlg('Error contacting nominated server: '+e.Message+'. Change Server?', mtError, [mbYes, mbNo], 0) = mrNo then
            close
          else
            WelcomeScreen1Click(self);
        end;
      end;
    end;
  end;
end;

procedure TForm5.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Context.Close;
  FormResize(self);
end;

procedure TForm5.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (Context <> nil) and (Context.Dirty) then
    CanClose := MessageDlg('Close and lose changes?', mtConfirmation, [mbYes, mbCancel], 0) = mrYes
  else
    CanClose := true;
end;

procedure TForm5.FormCreate(Sender: TObject);
var
  l, t, h, w : integer;
  s : TWindowState;
begin
  Context := TValueSetEditorContext.Create;
  Context.OnStateChange := ContextStateChange;
  Context.OnPreview := ShowPreview;
  Context.OnValidate := Validate;
  FOnCheckButtons := noButtons;

  if (Context.Settings.hasWindowState) then
  begin
    L := Context.Settings.WindowLeft;
    W := Context.Settings.WindowWidth;
    T := Context.Settings.WindowTop;
    H := Context.Settings.WindowHeight;
    S := TWindowState(Context.Settings.WindowState);

    Left := L;
    Width := W;
    Top := T;
    Height := H;
    WindowState := S;
  end;
  setDocoVisibility(Context.Settings.DocoVisible);
  if pnlDocumentation.visible then
    Constraints.MinWidth := 1100
  else
    Constraints.MinWidth := 800;

  MakeFullyVisible;

  btnNewClick(self);
  Refresh;
  ContextStateChange(nil);
  LocationChange(self);
end;

procedure TForm5.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm5.FormDestroy(Sender: TObject);
begin
  Context.Free;
  Context := nil;
end;

procedure TForm5.FormResize(Sender: TObject);
begin
  if (context <> nil) then
  begin
    Context.Settings.WindowState := ord(WindowState);
    Context.Settings.WindowLeft := Left;
    Context.Settings.WindowWidth := Width;
    Context.Settings.WindowTop := Top;
    Context.Settings.WindowHeight := Height;
  end;
end;

procedure TForm5.GetAbstractList(context: string; list: TStrings);
begin
  list.Add('');
  list.Add('abstract');
end;

procedure TForm5.Refresh;
begin
  FOnCheckButtons(self);
  LoadValuesetPage;
  PageControl1.ActivePage := tabInformation;
  ActiveControl := edtName;
end;

procedure TForm5.ShowPreview(sender: TObject);
begin
  tvPreview.RootNodeCount := 0;
  if (Context.Preview <> nil) then
    tvPreview.RootNodeCount := Context.Preview.containsList.Count;
end;

procedure TForm5.SetDocoVisibility(visible : boolean);
begin
  if visible then
  begin
    pnlDocumentation.Visible := true;
    Context.Settings.DocoVisible := true;
    Constraints.MinWidth := 1100;
  end
  else
  begin
    pnlDocumentation.Visible := false;
    Context.Settings.DocoVisible := false;
    Constraints.MinWidth := 800;
  end;
end;

procedure TForm5.miDocoClick(Sender: TObject);
begin
  setDocoVisibility(not pnlDocumentation.Visible);
end;

procedure TForm5.miPasteClick(Sender: TObject);
begin
  if ActiveControl is TEdit then
    TEdit(ActiveControl).PasteFromClipboard
  else if ActiveControl is TMemo then
    TMemo(ActiveControl).PasteFromClipboard;
end;

procedure TForm5.noButtons(sender: TObject);
begin
  tbInsert.Enabled := false;
  tbDelete.Enabled := false;
  tbUp.Enabled := false;
  tbDown.Enabled := false;
  tbIn.Enabled := false;
  tbOut.Enabled := false;
  miTvInsert.Enabled := false;
  miTvDelete.Enabled := false;
  miTvUp.Enabled := false;
  miTvDown.Enabled := false;
  miTvIn.Enabled := false;
  miTvOut.Enabled := false;
end;

procedure TForm5.miAboutClick(Sender: TObject);
begin
  ValueSetEditorAboutForm.showModal;
end;

procedure TForm5.miCopyClick(Sender: TObject);
begin
  if ActiveControl is TEdit then
    TEdit(ActiveControl).CopyToClipboard
  else if ActiveControl is TMemo then
    TMemo(ActiveControl).CopyToClipboard;
end;

procedure TForm5.miCutClick(Sender: TObject);
begin
  if ActiveControl is TEdit then
    TEdit(ActiveControl).CutToClipboard
  else if ActiveControl is TMemo then
    TMemo(ActiveControl).CutToClipboard;
end;

procedure TForm5.btnSaveAsClick(Sender: TObject);
var
  button: TControl;
  lowerLeft: TPoint;
begin
  if Sender is TControl then
  begin
    button := TControl(Sender);
    lowerLeft := Point(button.Left, button.Top + Button.Height);
    lowerLeft := ClientToScreen(lowerLeft);
    mnuSaveAs.Popup(lowerLeft.X, lowerLeft.Y);
  end;
end;

procedure TForm5.btnCloseClick(Sender: TObject);
begin
  if not Context.Dirty or (MessageDlg('Close and lose unsaved edits, are you sure?', mtConfirmation, [mbyes, mbcancel], 0) = mrYes) then
  begin
    Context.Close;
    Refresh;
  end;
end;


// --- Welcome page ------------------------------------------------------------

procedure TForm5.btnOpenFileClick(Sender: TObject);
begin
  if (opnValueSet.execute) then
  begin
    context.openFromFile(nil, opnValueSet.filename);
    Refresh;
  end;
end;

procedure TForm5.btnOpenServerClick(Sender: TObject);
begin
  ServerChooserForm.Context := Context.link;
  if ServerChooserForm.ShowModal = mrOk then
    Refresh;
end;

procedure TForm5.btnNewClick(Sender: TObject);
begin
  if not Context.Dirty or (MessageDlg('Lose unsaved edits, are you sure?', mtConfirmation, [mbyes, mbcancel], 0) = mrYes) then
  begin
    Context.NewValueset;
    Refresh;
  end;
end;


procedure TForm5.btnNewExcludeClick(Sender: TObject);
var
  n : PVirtualNode;
begin
  n := tvStructure.RootNode.FirstChild;
  n := n.NextSibling.NextSibling.NextSibling.NextSibling;
  tvStructure.FocusedNode := n;
  btnAddRuleClick(self);
end;

procedure TForm5.btnRedoClick(Sender: TObject);
begin
  if Context.Redo then
    LoadValuesetPage
  else
    MessageBeep(MB_ICONEXCLAMATION);
end;

procedure TForm5.btnSaveClick(Sender: TObject);
begin
  Context.Save;
end;

procedure TForm5.OpenfromUrl1Click(Sender: TObject);
var
  s : String;
  clip : TClipboard;
  done : boolean;
begin
  clip := TClipboard.Create;
  try
    s := clip.AsText;
  finally
    clip.free;
  end;
  if not IsURL(s) then
    s := '';
  done := false;
  while not done and InputQuery('Open from URL', 'URL to open', s) do
    try
      ServerOperation(context.openFromURL, s, 'Opening', true);
      done := true;
    except
      on e : exception do
      begin
        if not (e is EAbort) then
          MessageDlg(e.Message, mtError, [mbok], 0);
        done := false;
      end;
    end;
  if done then
   Refresh;
end;

procedure TForm5.OSer1Click(Sender: TObject);
begin
  Context.SaveAsServerNew;
end;

procedure TForm5.oServerasExisting1Click(Sender: TObject);
begin
  raise Exception.Create('Not Done Yet');
end;


procedure TForm5.LocationChange(Sender: TObject);
begin
  case PageControl1.ActivePageIndex of
    0:doco('metadata.htm');
    1:doco('definitions.htm');
    2:case Notebook2.PageIndex of
        0:doco('composition.htm');
        1:doco('import.htm');
        2:doco('include.htm');
      end;
    3:doco('evaluation.htm');
  else
    doco('');
  end;
end;

procedure TForm5.pmTreeViewPopup(Sender: TObject);
begin
  FOnCheckButtons(self);
end;

procedure TForm5.pmtvStructurePopup(Sender: TObject);
var
  p : PTreeDataPointer;
begin
  mnuStructureInsert.Enabled := false;
  mnuStructureDelete.Enabled := false;
  mnuStructureUp.Enabled := false;
  mnuStructureDown.Enabled := false;
  if tvStructure.FocusedNode <> nil then
  begin
    p := tvStructure.GetNodeData(tvStructure.FocusedNode);
    if Integer(p.obj) in [3..5] then // not a root or a (nil) holder
    begin
      mnuStructureInsert.Enabled := true;
    end
    else if p.obj = nil then
      mnuStructureInsert.Enabled := true
    else
    begin
      mnuStructureDelete.Enabled := true;
      mnuStructureUp.Enabled := tvStructure.FocusedNode.PrevSibling <> nil;
      mnuStructureDown.Enabled := tvStructure.FocusedNode.NextSibling <> nil;
    end;
  end;
end;

// --- Edit Page ---------------------------------------------------------------

procedure TForm5.LoadValuesetPage;
begin
  edtFilter.Text := Context.Settings.Filter;
  Caption := Context.EditName+' - ValueSet Editor';
  Notebook2.PageIndex := 0;
  tvDefines.Header.Columns[0].Width := Context.Settings.columnWidth('define', 'code', 100);
  tvDefines.Header.Columns[1].Width := Context.Settings.columnWidth('define', 'abstract', 70);
  tvDefines.Header.Columns[2].Width := Context.Settings.columnWidth('define', 'display', 200);
  tvDefines.Header.Columns[3].Width := Context.Settings.columnWidth('define', 'definition', 200);
  tvCodes.Header.Columns[0].Width := Context.Settings.columnWidth('codes', 'code', 200);
  tvCodes.Header.Columns[1].Width := Context.Settings.columnWidth('codes', 'display', 200);
  tvCodes.Header.Columns[2].Width := Context.Settings.columnWidth('codes', 'comments', 200);
  tvFilters.Header.Columns[0].Width := Context.Settings.columnWidth('filters', 'property', 150);
  tvFilters.Header.Columns[1].Width := Context.Settings.columnWidth('filters', 'op', 70);
  tvFilters.Header.Columns[2].Width := Context.Settings.columnWidth('filters', 'value', 200);
  tvExpansion.Header.Columns[0].Width := Context.Settings.columnWidth('expansion', 'system', 150);
  tvExpansion.Header.Columns[1].Width := Context.Settings.columnWidth('expansion', 'code', 70);
  tvExpansion.Header.Columns[2].Width := Context.Settings.columnWidth('expansion', 'display', 200);
  tvPreview.Header.Columns[0].Width := Context.Settings.columnWidth('preview', 'system', 150);
  tvPreview.Header.Columns[1].Width := Context.Settings.columnWidth('preview', 'code', 70);
  tvPreview.Header.Columns[2].Width := Context.Settings.columnWidth('preview', 'display', 200);

  loading := true;
  try
    if Context.ValueSet = nil then
    begin
      edtName.Text := '';
      cbxStatus.ItemIndex := 0;
      cbExperimental.Checked := false;
      edtIdentifier.Text := '';
      edtVersion.Text := '';
      edtPublisher.Text := '';
      edtCopyright.Text := '';
      edtPhone.Text := '';
      edtEmail.Text := '';
      edtWeb.Text := '';
      txtDescription.Text := '';
    end
    else
    begin
      edtName.Text := Context.ValueSet.name;
      cbxStatus.ItemIndex := Max(ord(Context.ValueSet.status) - 1, 0);
      cbExperimental.Checked := Context.ValueSet.experimental;
      edtIdentifier.Text := Context.ValueSet.url;
      edtVersion.Text := Context.ValueSet.version;
      edtPublisher.Text := Context.ValueSet.publisher;
      edtCopyright.Text := Context.ValueSet.copyright;
      edtPhone.Text := Context.ValueSet.contactList.System(ContactPointSystemPhone);
      edtEmail.Text := Context.ValueSet.contactList.System(ContactPointSystemEmail);
      edtWeb.Text := Context.ValueSet.contactList.System(ContactPointSystemUrl);
      txtDescription.Text := Context.ValueSet.description;
    end;

    ValidateEdit(edtName, Context.validateName(edtName.Text));
    ValidateMemo(txtDescription, Context.validateDescription(txtDescription.Text));
    ValidateEdit(edtIdentifier, Context.validateIdentifier(edtIdentifier.Text));

    if (Context.ValueSet <> nil) and (Context.ValueSet.define <> nil) then
    begin
      edtDefineURI.Text := Context.ValueSet.define.system;
      edtDefineVersion.Text := Context.ValueSet.define.version;
      cbDefineCase.Checked := Context.ValueSet.define.caseSensitive;
      tvDefines.RootNodeCount := 0;
      tvDefines.RootNodeCount := Context.ValueSet.define.conceptList.Count;

      ValidateEdit(edtDefineURI, context.validateSystem(edtDefineURI.Text));
    end
    else
    begin
      edtDefineURI.Text := '';
      edtDefineVersion.Text := '';
      cbDefineCase.Checked := false;
      tvDefines.RootNodeCount := 0;
    end;

    tvStructure.RootNodeCount := 0;
    tvStructure.RootNodeCount := 6;
    tvExpansion.RootNodeCount := 0;
    if Context.Expansion <> nil then
      tvExpansion.RootNodeCount := Context.Expansion.containsList.Count;
    tvStructureClick(self);
  finally
    loading := false;
  end;
end;

procedure TForm5.btnUndoClick(Sender: TObject);
begin
  if Context.Undo then
    LoadValuesetPage
  else
    MessageBeep(MB_ICONEXCLAMATION);
end;


procedure TForm5.cbExperimentalClick(Sender: TObject);
begin
  if not loading then
  begin
    Context.ValueSet.experimental := cbExperimental.Checked;
    Context.commit('exp');
  end;
end;

procedure TForm5.cbxStatusChange(Sender: TObject);
begin
  if not loading then
  begin
    Context.ValueSet.status := TFhirConformanceResourceStatus(cbxStatus.ItemIndex + 1);
    Context.commit('status');
  end;
end;

procedure TForm5.ContextStateChange(sender: TObject);
begin
  miUndo.Enabled := Context.CanUndo;
  miRedo.Enabled := Context.CanRedo;
  Caption := Context.EditName+' - Value Set Editor';
  FOnCheckButtons(self);
end;

procedure TForm5.edtCopyrightChange(Sender: TObject);
begin
  if not loading then
  begin
    Context.ValueSet.copyright := edtCopyright.Text;
    Context.commit('copy');
  end;
end;

procedure TForm5.edtDefineURIChange(Sender: TObject);
begin
  if not loading then
  begin
    if (Context.ValueSet.define = nil) then
      Context.ValueSet.define := TFhirValueSetDefine.Create;
    Context.ValueSet.define.system := edtDefineURI.Text;
    Context.commit('defineURI');
    ValidateEdit(edtDefineURI, context.validateSystem(edtDefineURI.Text));
  end;
end;

procedure TForm5.edtDefineVersionChange(Sender: TObject);
begin
  if not loading then
  begin
    if (Context.ValueSet.define = nil) then
      Context.ValueSet.define := TFhirValueSetDefine.Create;
    Context.ValueSet.define.version := edtDefineVersion.Text;
    Context.commit('defineversion');
  end;
end;

procedure TForm5.edtEmailChange(Sender: TObject);
begin
  if not loading then
  begin
    Context.ValueSet.contactList.SetSystem(ContactPointSystemEmail, edtEmail.Text);
    Context.commit('email');
  end;
end;

procedure TForm5.edtFilterChange(Sender: TObject);
begin
  Context.Settings.Filter := edtFilter.Text;
end;

procedure TForm5.edtIdentifierChange(Sender: TObject);
begin
  if not loading then
  begin
    Context.ValueSet.url := edtIdentifier.Text;
    Context.commit('identifier');
    ValidateEdit(edtIdentifier, Context.validateIdentifier(edtIdentifier.Text));
  end;
end;

procedure TForm5.edtImportUriChange(Sender: TObject);
var
  pr : PTreeDataPointer;
  p : PTreeDataPointer;
  ctxt : TFhirUri;
begin
  pr := tvStructure.GetNodeData(tvStructure.FocusedNode);
  if (pr = nil) then
    ctxt := nil
  else
    ctxt := TFhirUri(pr.obj);

  if not loading and (ctxt <> nil)  then
  begin
    ctxt.value := edtImportUri.text;
    ValidateCombo(edtImportUri, context.validateImport(edtImportUri.Text));
    Context.commit('include');
    tvStructure.Repaint;
    Context.GetPreview(edtImportUri.Text);
  end;
end;

procedure TForm5.edtImportUriEnter(Sender: TObject);
begin
  Context.GetList(VS_LIST, edtImportUri.StoredItems);
  edtImportUri.Items.Assign(edtImportUri.StoredItems);
end;

procedure TForm5.edtNameChange(Sender: TObject);
begin
  if not loading then
  begin
    Context.ValueSet.name := edtName.Text;
    Context.commit('name');
    if edtName.Text = '' then
      edtName.Color := COLOUR_MANDATORY
    else
      edtName.Color := COLOUR_OK;
  end;
end;

procedure TForm5.edtPhoneChange(Sender: TObject);
begin
  if not loading then
  begin
    Context.ValueSet.contactList.SetSystem(ContactPointSystemPhone, edtPhone.Text);
    Context.commit('phone');
  end;
end;

procedure TForm5.edtPublisherChange(Sender: TObject);
begin
  if not loading then
  begin
    Context.ValueSet.publisher := edtPublisher.Text;
    Context.commit('publisher');
  end;
end;

procedure TForm5.edtSystemReferenceChange(Sender: TObject);
var
  pr : PTreeDataPointer;
  p : PTreeDataPointer;
  ctxt : TFhirValueSetComposeInclude;
begin
  pr := tvStructure.GetNodeData(tvStructure.FocusedNode);
  if (pr = nil) then
    ctxt := nil
  else
    ctxt := TFhirValueSetComposeInclude(pr.obj);

  if not loading and (ctxt <> nil)  then
  begin
    ctxt.system := edtSystemReference.text;
    ValidateCombo(edtSystemReference, context.validateReference(edtSystemReference.Text));
    Context.commit('sysref');
    tvStructure.Invalidate;
  end;
end;

procedure TForm5.edtSystemReferenceEnter(Sender: TObject);
begin
  Context.GetList(CS_LIST, edtSystemReference.StoredItems);
  edtSystemReference.Items.Assign(edtSystemReference.StoredItems);
end;

procedure TForm5.edtSystemRefVersionChange(Sender: TObject);
var
  pr : PTreeDataPointer;
  p : PTreeDataPointer;
  ctxt : TFhirValueSetComposeInclude;
begin
  pr := tvStructure.GetNodeData(tvStructure.FocusedNode);
  if (pr = nil) then
    ctxt := nil
  else
    ctxt := TFhirValueSetComposeInclude(pr.obj);

  if not loading and (ctxt <> nil)  then
  begin
    ctxt.version := edtSystemRefVersion.text;
    Context.commit('sysrefver');
  end;
end;

procedure TForm5.edtVersionChange(Sender: TObject);
begin
  if not loading then
  begin
    Context.ValueSet.version := edtVersion.Text;
    Context.commit('version');
  end;
end;

procedure TForm5.edtWebChange(Sender: TObject);
begin
  if not loading then
  begin
    Context.ValueSet.contactList.SetSystem(ContactPointSystemUrl, edtWeb.Text);
    Context.commit('web');
  end;
end;

procedure TForm5.txtDescriptionChange(Sender: TObject);
begin
  if not loading then
  begin
    Context.ValueSet.description := txtDescription.Text;
    Context.commit('desc');
    if txtDescription.Text = '' then
      txtDescription.Color := COLOUR_MANDATORY
    else
      txtDescription.Color := COLOUR_OK;
  end;
end;


procedure TForm5.Validate(sender: TObject);
begin
  FOnCheckButtons(self);
  ValidateEdit(edtIdentifier, Context.validateIdentifier(edtIdentifier.Text));
  ValidateEdit(edtDefineURI, Context.validateSystem(edtDefineURI.Text));
  ValidateCombo(edtImportUri, Context.validateImport(edtImportUri.Text));
  ValidateCombo(edtSystemReference, Context.validateReference(edtSystemReference.Text));
  ValidateEdit(edtName, Context.validateName(edtName.Text));
  ValidateMemo(txtDescription, Context.validateDescription(txtDescription.Text));
end;

procedure TForm5.ValidateEdit(edit: TEdit; outcome : TValidationOutcome);
begin
  if outcome.kind = voOk then
  begin
    edit.ParentShowHint := false;
    edit.ShowHint := false;
    edit.Hint := '';
    edit.Color := COLOUR_OK;
  end
  else
  begin
    edit.ParentShowHint := false;
    edit.ShowHint := true;
    edit.Hint := outcome.msg;
    case outcome.kind of
      voMissing: edit.Color := COLOUR_MANDATORY;
      voError: edit.Color := COLOUR_ERROR;
      voWarning: edit.Color := COLOUR_WARNING;
      voHint : edit.Color := COLOUR_HINT;
    end;
  end;
end;

procedure TForm5.ValidateCombo(combo: TCombobox; outcome : TValidationOutcome);
begin
  if outcome.kind = voOk then
  begin
    combo.ParentShowHint := false;
    combo.ShowHint := false;
    combo.Hint := '';
    combo.Color := COLOUR_OK;
  end
  else
  begin
    combo.ParentShowHint := false;
    combo.ShowHint := true;
    combo.Hint := outcome.msg;
    case outcome.kind of
      voMissing: combo.Color := COLOUR_MANDATORY;
      voError: combo.Color := COLOUR_ERROR;
      voWarning: combo.Color := COLOUR_WARNING;
      voHint : combo.Color := COLOUR_HINT;
    end;
  end;
end;

procedure TForm5.ValidateMemo(memo : TMemo; outcome : TValidationOutcome);
begin
  if outcome.kind = voOk then
  begin
    memo.ParentShowHint := false;
    memo.ShowHint := false;
    memo.Hint := '';
    memo.Color := COLOUR_OK;
  end
  else
  begin
    memo.ParentShowHint := false;
    memo.ShowHint := true;
    memo.Hint := outcome.msg;
    case outcome.kind of
      voMissing: memo.Color := COLOUR_MANDATORY;
      voError: memo.Color := COLOUR_ERROR;
      voWarning: memo.Color := COLOUR_WARNING;
    end;
  end;
end;

procedure TForm5.WelcomeScreen1Click(Sender: TObject);
begin
  ValueSetEditorWelcomeForm.Context := Context.Link;
  ValueSetEditorWelcomeForm.showModal;
  Context.Settings.HasViewedWelcomeScreen := true;
end;

procedure TForm5.tvDefinesBeforeCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
var
  p : PTreeDataPointer;
  c : TFhirValueSetDefineConcept;
  kind : TValidationOutcomeKind;
  msg : String;
begin
  p := Sender.GetNodeData(Node);
  c := TFhirValueSetDefineConcept(p.obj);
  if Context.checkValidation(c, column, kind, msg) and (kind <> voOK) then
  begin
    case kind of
      voMissing: TargetCanvas.Brush.Color := COLOUR_MANDATORY;
      voError: TargetCanvas.Brush.Color := COLOUR_ERROR;
      voWarning: TargetCanvas.Brush.Color := COLOUR_WARNING;
      voHint : TargetCanvas.Brush.Color := COLOUR_HINT;
    end;
    TargetCanvas.Brush.Style := bsSolid;
    TargetCanvas.FillRect(CellRect);
  end;
end;

procedure TForm5.tvDefinesColumnResize(Sender: TVTHeader; Column: TColumnIndex);
begin
  case column of
    0 : Context.Settings.setColumnWidth('define', 'code', tvDefines.Header.Columns[0].width);
    1 : Context.Settings.setColumnWidth('define', 'abstract', tvDefines.Header.Columns[1].width);
    2 : Context.Settings.setColumnWidth('define', 'display', tvDefines.Header.Columns[2].width);
    3 : Context.Settings.setColumnWidth('define', 'definition', tvDefines.Header.Columns[3].width);
  end;
end;

procedure TForm5.tvCodesBeforeCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellPaintMode: TVTCellPaintMode; CellRect: TRect; var ContentRect: TRect);
var
  p : PTreeDataPointer;
  c : TFhirCode;
  kind : TValidationOutcomeKind;
  msg : String;
begin
  p := Sender.GetNodeData(Node);
  c := TFhirCode(p.obj);
  if Context.checkValidation(c, column, kind, msg) and (kind <> voOK) then
  begin
    case kind of
      voMissing: TargetCanvas.Brush.Color := COLOUR_MANDATORY;
      voError: TargetCanvas.Brush.Color := COLOUR_ERROR;
      voWarning: TargetCanvas.Brush.Color := COLOUR_WARNING;
      voHint : TargetCanvas.Brush.Color := COLOUR_HINT;
    end;
    TargetCanvas.Brush.Style := bsSolid;
    TargetCanvas.FillRect(CellRect);
  end;
end;

procedure TForm5.tvCodesColumnResize(Sender: TVTHeader; Column: TColumnIndex);
begin
  case column of
    0 : Context.Settings.setColumnWidth('codes', 'code', tvCodes.Header.Columns[0].width);
    1 : Context.Settings.setColumnWidth('codes', 'display', tvCodes.Header.Columns[1].width);
    2 : Context.Settings.setColumnWidth('codes', 'comments', tvCodes.Header.Columns[2].width);
  end;
end;

procedure TForm5.tvFiltersColumnResize(Sender: TVTHeader; Column: TColumnIndex);
begin
  case column of
    0 : Context.Settings.setColumnWidth('filters', 'property', tvFilters.Header.Columns[0].width);
    1 : Context.Settings.setColumnWidth('filters', 'op', tvFilters.Header.Columns[1].width);
    2 : Context.Settings.setColumnWidth('filters', 'value', tvFilters.Header.Columns[2].width);
  end;
end;


procedure TForm5.tvExpansionColumnResize(Sender: TVTHeader; Column: TColumnIndex);
begin
  case column of
    0 : Context.Settings.setColumnWidth('expansion', 'system', tvExpansion.Header.Columns[0].width);
    1 : Context.Settings.setColumnWidth('expansion', 'code', tvExpansion.Header.Columns[1].width);
    2 : Context.Settings.setColumnWidth('expansion', 'display', tvExpansion.Header.Columns[2].width);
  end;
end;

procedure TForm5.tvPreviewColumnResize(Sender: TVTHeader; Column: TColumnIndex);
begin
  case column of
    0 : Context.Settings.setColumnWidth('preview', 'system', tvPreview.Header.Columns[0].width);
    1 : Context.Settings.setColumnWidth('preview', 'code', tvPreview.Header.Columns[1].width);
    2 : Context.Settings.setColumnWidth('preview', 'display', tvPreview.Header.Columns[2].width);
  end;
end;


procedure TForm5.tvDefinesInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  list : TFhirValueSetDefineConceptList;
  pp, p : PTreeDataPointer;
begin
  if parentNode = nil then
    list := Context.ValueSet.define.conceptList
  else
  begin
    pp := tvDefines.GetNodeData(parentNode);
    list := TFhirValueSetDefineConcept(pp.obj).conceptList;
  end;
  p := tvDefines.GetNodeData(Node);
  p.obj := list[Node.Index];
  if list[node.Index].conceptList.Count > 0 then
     InitialStates := [ivsHasChildren];
end;

procedure TForm5.tvDefinesKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  if CharInSet(AnsiChar(Key), ['A'..'Z', '0'..'9']) then
  begin
    if ssShift in shift then
      FFirstChar := AnsiChar(Key)
    else
      FFirstChar := lowercase(AnsiChar(Key));
    tvDefines.EditNode(tvDefines.FocusedNode, tvDefines.FocusedColumn);
  end;
end;

procedure TForm5.tvDefinesInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  p : PTreeDataPointer;
  c : TFhirValueSetDefineConcept;
begin
  p := tvDefines.GetNodeData(node);
  c := TFhirValueSetDefineConcept(p.obj);
  ChildCount := c.conceptList.Count;
end;

procedure TForm5.tvAllGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle; var HintText: string);
var
  p : PTreeDataPointer;
  c : TFhirValueSetDefineConcept;
  kind : TValidationOutcomeKind;
  msg : String;
begin
  p := Sender.GetNodeData(Node);
  c := TFhirValueSetDefineConcept(p.obj);
  if Context.checkValidation(c, column, kind, msg) then
    HintText := msg;
end;

procedure TForm5.tvAllGetHintKind(sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Kind: TVTHintKind);
begin
  Kind := vhkText;
end;

procedure TForm5.tvDefinesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  p : PTreeDataPointer;
  c : TFhirValueSetDefineConcept;
begin
  p := tvDefines.GetNodeData(Node);
  c := TFhirValueSetDefineConcept(p.obj);
  case Column of
    0: CellText := c.code;
    1: if c.abstract then CellText := 'abstract' else CellText := '';
    2: CellText := c.display;
    3: CellText := c.definition;
  end;
end;

procedure TForm5.defineCheckButtons(sender : TObject);
var
  p : PTreeDataPointer;
  ctxt : TFhirValueSetDefineConceptList;
begin
  tbInsert.Enabled := not tvDefines.IsEditing and (Context.ValueSet <> nil);
  tbDelete.Enabled := not tvDefines.IsEditing and (tvDefines.FocusedNode <> nil);
  tbUp.Enabled := false;
  tbDown.Enabled := false;
  tbIn.Enabled := false;
  tbOut.Enabled := false;
  if not tvDefines.IsEditing and (tvDefines.FocusedNode <> nil) then
  begin
    tbIn.Enabled := false;
    p := tvDefines.GetNodeData(tvDefines.FocusedNode.Parent);
    if (p = nil) then
      ctxt := Context.ValueSet.define.conceptList
    else
    begin
      ctxt := TFhirValueSetDefineConcept(p.obj).conceptList;
      tbIn.Enabled := tvDefines.GetNodeData(tvDefines.FocusedNode.Parent) <> nil;
    end;
    tbUp.Enabled := tvDefines.FocusedNode.Index > 0;
    tbDown.Enabled := (tvDefines.FocusedNode.Index < ctxt.Count - 1);
    tbOut.Enabled := tvDefines.FocusedNode.Index > 0;
  end;
  miTvInsert.Enabled := tbInsert.Enabled;
  miTvDelete.Enabled := tbDelete.Enabled;
  miTvUp.Enabled := tbUp.Enabled;
  miTvDown.Enabled := tbDown.Enabled;
  miTvIn.Enabled := tbIn.Enabled;
  miTvOut.Enabled := tbOut.Enabled;
end;


procedure TForm5.doco(filename: String);
var
  fn : String;
begin
  fn := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(ExtractFilePath(paramstr(0)))+'doco')+filename;
  if not FileExists(fn) then
    fn := 'C:\work\com.healthintersections.fhir\ValueSetEditor\doco\'+filename;
  webDoco.Navigate2('file:'+fn);
end;

function TForm5.EditValue(text: String): String;
begin
  if (FFirstChar <> '') then
    result := FFirstChar
  else
    result := text;
end;

procedure TForm5.btnAddDefineClick(Sender: TObject);
var
  p : PTreeDataPointer;
  ctxt : TFhirValueSetDefineConceptList;
begin
  if not tvDefines.IsEditing then
  begin
  if Context.ValueSet.define = nil then
    Context.ValueSet.define := TFhirValueSetDefine.Create;
  if tvDefines.FocusedNode = nil then
    ctxt := Context.ValueSet.define.conceptList
  else
  begin
    p := tvDefines.GetNodeData(tvDefines.FocusedNode);
    ctxt := TFhirValueSetDefineConcept(p.obj).conceptList;
  end;

  ctxt.Append.code := 'code';
  Context.Commit('');
  if (ctxt <> Context.ValueSet.define.conceptList)  then
    tvDefines.ReinitNode(tvDefines.FocusedNode, true)
  else
  begin
    tvDefines.RootNodeCount := 0;
    tvDefines.RootNodeCount := Context.ValueSet.define.conceptList.Count;
  end;
  end
  else
    MessageBeep(MB_ICONEXCLAMATION);
end;

procedure TForm5.btnDeleteDefineClick(Sender: TObject);
var
  p : PTreeDataPointer;
  ctxt : TFhirValueSetDefineConcept;
begin
  if not tvDefines.IsEditing and (tvDefines.FocusedNode <> nil) then
  begin
    p := tvDefines.GetNodeData(tvDefines.FocusedNode.Parent);
    if (p = nil) then
      ctxt := nil
    else
      ctxt := TFhirValueSetDefineConcept(p.obj);
    if ctxt = nil then
    begin
      Context.ValueSet.define.conceptList.DeleteByIndex(tvDefines.FocusedNode.Index);
      tvDefines.RootNodeCount := 0;
      tvDefines.RootNodeCount := Context.ValueSet.define.conceptList.Count;
    end
    else
    begin
      ctxt.conceptList.DeleteByIndex(tvDefines.FocusedNode.Index);
      tvDefines.ReInitNode(tvDefines.FocusedNode.Parent, true);
    end;
    Context.commit('');
  end
  else
    MessageBeep(MB_ICONEXCLAMATION);
end;

procedure TForm5.btnDefineDownClick(Sender: TObject);
var
  p : PTreeDataPointer;
  ctxt : TFhirValueSetDefineConcept;
begin
  if (tvDefines.FocusedNode <> nil) then
  begin
    p := tvDefines.GetNodeData(tvDefines.FocusedNode.Parent);
    if (p = nil) then
      ctxt := nil
    else
      ctxt := TFhirValueSetDefineConcept(p.obj);
    if ctxt = nil then
    begin
      if (tvDefines.FocusedNode.Index < Context.ValueSet.define.conceptList.Count - 1) then
      begin
        Context.ValueSet.define.conceptList.Exchange(tvDefines.FocusedNode.Index + 1, tvDefines.FocusedNode.Index);
        tvDefines.RootNodeCount := 0;
        tvDefines.RootNodeCount := Context.ValueSet.define.conceptList.Count;
      end
      else
        MessageBeep(MB_ICONEXCLAMATION);
    end
    else
    begin
      if (tvDefines.FocusedNode.Index < ctxt.conceptList.Count - 1) then
      begin
        ctxt.conceptList.Exchange(tvDefines.FocusedNode.Index + 1, tvDefines.FocusedNode.Index);
        tvDefines.ReinitNode(tvDefines.FocusedNode.Parent, true);
      end
      else
        MessageBeep(MB_ICONEXCLAMATION);
    end;
    Context.commit('');
  end
  else
    MessageBeep(MB_ICONEXCLAMATION);
end;

procedure TForm5.btnDefineLeftClick(Sender: TObject);
var
  p, pp : PTreeDataPointer;
  ctxt, pCtxt : TFhirValueSetDefineConceptList;
begin
  if (tvDefines.FocusedNode <> nil) then
  begin
    p := tvDefines.GetNodeData(tvDefines.FocusedNode.Parent);
    if (p <> nil) then
    begin
      ctxt := TFhirValueSetDefineConcept(p.obj).ConceptList;
      pp := tvDefines.GetNodeData(tvDefines.FocusedNode.Parent.Parent);
      if pp = nil then
        pCtxt := Context.Valueset.Define.ConceptList
      else
        pctxt := TFhirValueSetDefineConcept(pp.obj).ConceptList;

      pctxt.add(ctxt[tvDefines.FocusedNode.Index].Link);
      ctxt.DeleteByIndex(tvDefines.FocusedNode.Index);
      if pp = nil then
      begin
        tvDefines.RootNodeCount := 0;
        tvDefines.RootNodeCount := pCtxt.Count;
      end
      else
        tvDefines.ReinitNode(tvDefines.FocusedNode.Parent.Parent, true);
      Context.commit('');
    end
    else
      MessageBeep(MB_ICONEXCLAMATION);
  end
  else
    MessageBeep(MB_ICONEXCLAMATION);
end;

procedure TForm5.btnDefineRightClick(Sender: TObject);
var
  p : PTreeDataPointer;
  ctxt : TFhirValueSetDefineConcept;
begin
  if (tvDefines.FocusedNode <> nil) and (tvDefines.FocusedNode.Index > 0) then
  begin
    p := tvDefines.GetNodeData(tvDefines.FocusedNode.Parent);
    if (p = nil) then
      ctxt := nil
    else
      ctxt := TFhirValueSetDefineConcept(p.obj);
    if ctxt = nil then
    begin
      Context.ValueSet.define.conceptList[tvDefines.FocusedNode.Index - 1].conceptList.add(Context.ValueSet.define.conceptList[tvDefines.FocusedNode.Index].Link);
      Context.ValueSet.define.conceptList.DeleteByIndex(tvDefines.FocusedNode.Index);
      tvDefines.RootNodeCount := 0;
      tvDefines.RootNodeCount := Context.ValueSet.define.conceptList.Count;
    end
    else
    begin
      ctxt.conceptList[tvDefines.FocusedNode.Index - 1].conceptList.add(ctxt.conceptList[tvDefines.FocusedNode.Index].Link);
      ctxt.conceptList.DeleteByIndex(tvDefines.FocusedNode.Index);
      tvDefines.ReinitNode(tvDefines.FocusedNode.Parent, true);
    end;
    Context.commit('');
  end
  else
    MessageBeep(MB_ICONEXCLAMATION);
end;

procedure TForm5.btnDefineUpClick(Sender: TObject);
var
  p : PTreeDataPointer;
  ctxt : TFhirValueSetDefineConcept;
begin
  if (tvDefines.FocusedNode <> nil) and (tvDefines.FocusedNode.Index > 0) then
  begin
    p := tvDefines.GetNodeData(tvDefines.FocusedNode.Parent);
    if (p = nil) then
      ctxt := nil
    else
      ctxt := TFhirValueSetDefineConcept(p.obj);
    if ctxt = nil then
    begin
      Context.ValueSet.define.conceptList.Exchange(tvDefines.FocusedNode.Index - 1, tvDefines.FocusedNode.Index);
      tvDefines.RootNodeCount := 0;
      tvDefines.RootNodeCount := Context.ValueSet.define.conceptList.Count;
    end
    else
    begin
      ctxt.conceptList.Exchange(tvDefines.FocusedNode.Index - 1, tvDefines.FocusedNode.Index);
      tvDefines.ReinitNode(tvDefines.FocusedNode.Parent, true);
    end;
    Context.commit('');
  end
  else
    MessageBeep(MB_ICONEXCLAMATION);
end;


procedure TForm5.tvDefinesCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
var
  p : PTreeDataPointer;
  c : TFhirValueSetDefineConcept;
begin
  p := tvDefines.GetNodeData(Node);
  c := TFhirValueSetDefineConcept(p.obj);
  case Column of
    0: EditLink := TVirtualStringTreeEdit.Create(EditValue(c.code), FFirstChar <> '');
    1: if c.abstract then
      EditLink := TVirtualStringTreeComboBox.Create('abstract', true, GetAbstractList, '')
    else
      EditLink := TVirtualStringTreeComboBox.Create('', true, GetAbstractList, '');
    2: EditLink := TVirtualStringTreeEdit.Create(EditValue(c.display), FFirstChar <> '');
    3: EditLink := TVirtualStringTreeEdit.Create(EditValue(c.definition), FFirstChar <> '');
  else
    EditLink := nil;
  end;
  FFirstChar := '';
end;

procedure TForm5.tvDefinesEditCancelled(Sender: TBaseVirtualTree; Column: TColumnIndex);
begin
  defineCheckButtons(self);
end;

procedure TForm5.tvDefinesEdited(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
begin
  defineCheckButtons(self);
end;

procedure TForm5.tvDefinesEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  defineCheckButtons(self);
end;

procedure TForm5.tvDefinesEnter(Sender: TObject);
begin
  FOnCheckButtons := defineCheckButtons;
  tbInsert.OnClick := btnAddDefineClick;
  tbDelete.OnClick := btnDeleteDefineClick;
  tbUp.OnClick := btnDefineUpClick;
  tbDown.OnClick := btnDefineDownClick;
  tbIn.OnClick := btnDefineLeftClick;
  tbOut.OnClick := btnDefineRightClick;
  miTvInsert.OnClick := tbInsert.OnClick;
  miTvDelete.OnClick := tbDelete.OnClick;
  miTvUp.OnClick := tbUp.OnClick;
  miTvDown.OnClick := tbDown.OnClick;
  miTvIn.OnClick := tbIn.OnClick;
  miTvOut.OnClick := tbOut.OnClick;
  defineCheckButtons(self);
end;

procedure TForm5.tvDefinesExit(Sender: TObject);
begin
  tbInsert.OnClick := nil;
  tbDelete.OnClick := nil;
  tbUp.OnClick := nil;
  tbDown.OnClick := nil;
  tbIn.OnClick := nil;
  tbOut.OnClick := nil;
  miTvInsert.OnClick := tbInsert.OnClick;
  miTvDelete.OnClick := tbDelete.OnClick;
  miTvUp.OnClick := tbUp.OnClick;
  miTvDown.OnClick := tbDown.OnClick;
  miTvIn.OnClick := tbIn.OnClick;
  miTvOut.OnClick := tbOut.OnClick;
  FOnCheckButtons := noButtons;
  FOnCheckButtons(self);
end;

procedure TForm5.tvDefinesFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
begin
  FOnCheckButtons(self);
end;


procedure TForm5.tvDefinesNewText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; NewText: string);
var
  p : PTreeDataPointer;
  c : TFhirValueSetDefineConcept;
begin
  p := tvDefines.GetNodeData(Node);
  c := TFhirValueSetDefineConcept(p.obj);
  case Column of
    0: c.code := NewText;
    1: c.abstract := NewText <> '';
    2: c.display := NewText;
    3: c.definition := NewText;
  end;
  Context.commit('');
end;

procedure TForm5.tvStructureInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  p, pp : PTreeDataPointer;
  c : integer;
begin
  c := 0;
  p := tvStructure.GetNodeData(node);
  if ParentNode = nil then
  begin
    // one of the 6 parent nodes
    p.obj := TObject(node.Index+1);
    InitialStates := [ivsExpanded, ivsHasChildren];
  end
  else
  begin
    pp := tvStructure.GetNodeData(parentnode);
    p.obj := nil;
    if (Context <> nil) and (Context.ValueSet <> nil) and (Context.ValueSet.Compose <> nil) then
      case integer(pp.obj) of
        3: if Context.ValueSet.compose.importList.Count > node.index then p.obj := Context.ValueSet.compose.importList[node.Index];
        4: if Context.ValueSet.compose.includeList.Count > node.index then p.obj := Context.ValueSet.compose.includeList[node.Index];
        5: if Context.ValueSet.compose.excludeList.Count > node.index then p.obj := Context.ValueSet.compose.excludeList[node.Index];
      end;
  end;
end;

procedure TForm5.tvStructureInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  p : PTreeDataPointer;
begin
  p := tvStructure.GetNodeData(node);
  ChildCount := 0;
  if (Context <> nil) and (Context.ValueSet <> nil) and (Context.ValueSet.Compose <> nil) then
    case integer(p.obj) of
      3: ChildCount := Max(1, Context.ValueSet.compose.importList.Count);
      4: ChildCount := Max(1, Context.ValueSet.compose.includeList.Count);
      5: ChildCount := Max(1, Context.ValueSet.compose.excludeList.Count);
    end
  else if integer(p.obj) in [3..5] then
    ChildCount := 1;
end;


procedure TForm5.tvStructurePaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
var
  p : PTreeDataPointer;
begin
  p := tvStructure.GetNodeData(node);
  if integer(p.obj) < 10 then
    TargetCanvas.Font.Style := [fsBold]
  else
    TargetCanvas.Font.Style := [];
end;

procedure TForm5.tvStructureGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  p : PTreeDataPointer;
  elem : TFhirElement;
begin
  p := tvStructure.GetNodeData(node);
  if p.obj = nil then
    CellText := '(nil)';
  if integer(p.obj) < 10 then
    case integer(p.obj) of
      1: CellText := NAME_INFORMATION;
      2: CellText := NAME_DEFINE;
      3: CellText := NAME_IMPORT+':';
      4: CellText := NAME_INCLUDE+':';
      5: CellText := NAME_EXCLUDE+':';
      6: CellText := NAME_EXPAND;
    end
  else
  begin
    elem := TFhirElement(p.obj);
    if elem is TFHIRURI then
      CellText := Context.NameValueSet(TFHIRURI(elem).value)
    else if elem is TFhirValueSetComposeInclude then
      CellText := Context.NameCodeSystem(TFhirValueSetComposeInclude(elem).system)
    else
      CellText := '??';
  end;
end;

procedure TForm5.tvStructureFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
begin
  FOnCheckButtons(self);
end;

procedure TForm5.btnAddRuleClick(sender : TObject);
var
  n : PVirtualNode;
  p : PTreeDataPointer;
begin
  if (Context.ValueSet <> nil) and (tvStructure.FocusedNode <> nil) then
  begin
    n := tvStructure.FocusedNode;
    p := tvStructure.GetNodeData(n);
    if not (Integer(p.obj) in [3..5]) then
    begin
      n := tvStructure.FocusedNode.Parent;
      p := tvStructure.GetNodeData(n);
    end;
    if Context.ValueSet.compose = nil then
      Context.ValueSet.compose := TFhirValueSetCompose.Create;
    case integer(p.obj) of
      3: Context.ValueSet.compose.importList.Append;
      4: Context.ValueSet.compose.includeList.Append;
      5: Context.ValueSet.compose.excludeList.Append;
    else
      MessageBeep(MB_ICONEXCLAMATION);
    end;
    Context.commit('');
    tvStructure.ReinitNode(n, true);
    tvStructure.FocusedNode := n.LastChild;
    tvStructureClick(self);
  end
  else
    MessageBeep(MB_ICONEXCLAMATION);
end;


procedure TForm5.btnDeleteRuleClick(sender : TObject);
var
  n : PVirtualNode;
  p : PTreeDataPointer;
begin
  if (Context.ValueSet <> nil) and (tvStructure.FocusedNode <> nil) then
  begin
    n := tvStructure.FocusedNode;
    p := tvStructure.GetNodeData(n);
    if not (Integer(p.obj) in [3..5]) then
    begin
      p := tvStructure.GetNodeData(tvStructure.FocusedNode.Parent);
      case integer(p.obj) of
        3: Context.ValueSet.compose.importList.DeleteByIndex(n.Index);
        4: Context.ValueSet.compose.includeList.DeleteByIndex(n.Index);
        5: Context.ValueSet.compose.excludeList.DeleteByIndex(n.Index);
      end;
      Context.Commit('');
      tvStructure.RootNodeCount := 0;
      tvStructure.RootNodeCount := 6;
      tvStructureClick(self);
    end;
  end;
end;

procedure TForm5.btnRuleUpClick(sender : TObject);
begin
  raise Exception.Create('To Do');
end;

procedure TForm5.btnRuleDownClick(sender : TObject);
begin
  raise Exception.Create('To Do');
end;

procedure TForm5.tvStructureClick(Sender: TObject);
var
  p : PTreeDataPointer;
  elem : TFhirElement;
begin
  Context.UndoBreak;
  p := tvStructure.GetNodeData(tvStructure.FocusedNode);
  if (p <> nil) then
  begin
    if p.obj = nil then
    begin
      PageControl1.ActivePage := tabComposition;
      Notebook2.PageIndex := 0;
    end
    else if integer(p.obj) > 10 then
    begin
      elem := TFhirElement(p.obj);
      if elem is TFHIRURI then
      begin
        PageControl1.ActivePage := tabComposition;
        Notebook2.PageIndex := 1;
        edtImportUri.Text := TFHIRURI(elem).value;
        ValidateCombo(edtImportUri, context.validateImport(edtImportUri.Text));
        Context.GetPreview(edtImportUri.Text);
      end
      else // elem is TFhirValueSetComposeInclude then
      begin
        Notebook2.PageIndex := 2;
        loading := true;
        try
          edtSystemReference.Text := TFhirValueSetComposeInclude(elem).system;
          ValidateCombo(edtSystemReference, context.validateReference(edtSystemReference.Text));
          edtSystemRefVersion.Text := TFhirValueSetComposeInclude(elem).version;
          Context.PrepareSystemContext(TFhirValueSetComposeInclude(elem).system, TFhirValueSetComposeInclude(elem).version);
          tvCodes.RootNodeCount := 0;
          tvCodes.RootNodeCount := TFhirValueSetComposeInclude(elem).conceptList.Count;
          tvFilters.RootNodeCount := 0;
          tvFilters.RootNodeCount := TFhirValueSetComposeInclude(elem).filterList.Count;
          if tvFilters.RootNodeCount > 0 then
            Context.PrepareSystemContext('http://hl7.org/fhir/filter-operator', '');
        finally
          loading := false;
        end;
      end
    end
    else if integer(p.obj) = 1 then
      PageControl1.ActivePage := tabInformation
    else if integer(p.obj) = 2 then
      PageControl1.ActivePage := tabDefined
    else if integer(p.obj) = 6 then
      PageControl1.ActivePage := tabExpansion
    else
    begin
      PageControl1.ActivePage := tabComposition;
      Notebook2.PageIndex := 0;
    end;
  end;
end;


// up to here --------------------------------------------------------------------------------------

procedure TForm5.tvCodesEnter(Sender: TObject);
begin
  FOnCheckButtons := codesCheckButtons;
  tbInsert.OnClick := btnAddCodeClick;
  tbDelete.OnClick := btnDeleteCodeClick;
  tbUp.OnClick := btnCodesUpClick;
  tbDown.OnClick := btnCodesDownClick;
  miTvInsert.OnClick := tbInsert.OnClick;
  miTvDelete.OnClick := tbDelete.OnClick;
  miTvUp.OnClick := tbUp.OnClick;
  miTvDown.OnClick := tbDown.OnClick;
  codesCheckButtons(self);
end;

procedure TForm5.tvCodesExit(Sender: TObject);
begin
  tbInsert.OnClick := nil;
  tbDelete.OnClick := nil;
  tbUp.OnClick := nil;
  tbDown.OnClick := nil;
  tbIn.OnClick := nil;
  tbOut.OnClick := nil;
  miTvInsert.OnClick := tbInsert.OnClick;
  miTvDelete.OnClick := tbDelete.OnClick;
  miTvUp.OnClick := tbUp.OnClick;
  miTvDown.OnClick := tbDown.OnClick;
  miTvIn.OnClick := tbIn.OnClick;
  miTvOut.OnClick := tbOut.OnClick;
  FOnCheckButtons := noButtons;
  FOnCheckButtons(self);
end;

procedure TForm5.tvCodesFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
begin
  FOnCheckButtons(self);
end;

procedure TForm5.codesCheckButtons(sender : TObject);
var
  p : PTreeDataPointer;
begin
  tbInsert.Enabled := true; // never any reason not to
  tbDelete.Enabled := tvCodes.FocusedNode <> nil;
  tbUp.Enabled := false;
  tbDown.Enabled := false;
  if tvCodes.FocusedNode <> nil then
  begin
    tbUp.Enabled := tvCodes.FocusedNode.Index > 0;
    tbDown.Enabled := tvCodes.FocusedNode.Index < tvCodes.FocusedNode.Parent.ChildCount - 1;
  end;
  tbIn.Enabled := False;
  tbOut.Enabled := False;

  miTvInsert.Enabled := tbInsert.Enabled;
  miTvDelete.Enabled := tbDelete.Enabled;
  miTvUp.Enabled := tbUp.Enabled;
  miTvDown.Enabled := tbDown.Enabled;
  miTvIn.Enabled := tbIn.Enabled;
  miTvOut.Enabled := tbOut.Enabled;
end;


procedure TForm5.tvCodesInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  pr : PTreeDataPointer;
  p : PTreeDataPointer;
  ctxt : TFhirValueSetComposeInclude;
begin
  pr := tvStructure.GetNodeData(tvStructure.FocusedNode);
  ctxt := TFhirValueSetComposeInclude(pr.obj);
  p := tvCodes.GetNodeData(Node);
  p.obj := ctxt.conceptList[Node.Index];
end;

procedure TForm5.tvCodesKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if CharInSet(AnsiChar(Key), ['A'..'Z', '0'..'9']) then
  begin
    if ssShift in shift then
      FFirstChar := AnsiChar(Key)
    else
      FFirstChar := lowercase(AnsiChar(Key));
    tvCodes.EditNode(tvCodes.FocusedNode, tvCodes.FocusedColumn);
  end;
end;

procedure TForm5.tvCodesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  p : PTreeDataPointer;
  pr : PTreeDataPointer;
  code : TFhirCode;
  ctxt : TFhirValueSetComposeInclude;
begin
  p := tvCodes.GetNodeData(Node);
  code := TFhirCode(p.obj);
  case Column of
    0: CellText := code.value;
    1: begin
         CellText := code.getExtensionString('http://hl7.org/fhir/Profile/tools-extensions#display');
         if CellText = '' then
         begin
           if code.Tags['value'] = '' then
           begin
             pr := tvStructure.GetNodeData(tvStructure.FocusedNode);
             ctxt := TFhirValueSetComposeInclude(pr.obj);
             code.Tags['value']  := Context.TryGetDisplay(ctxt.system, code.value);
           end;
           CellText := code.Tags['value'];
         end;
       end;
    2: CellText := code.getExtensionString('http://hl7.org/fhir/Profile/tools-extensions#comment');
  end;
end;

procedure TForm5.btnAddCodeClick(Sender: TObject);
var
  pr : PTreeDataPointer;
  ctxt : TFhirValueSetComposeInclude;
begin
  pr := tvStructure.GetNodeData(tvStructure.FocusedNode);
  ctxt := TFhirValueSetComposeInclude(pr.obj);
  ctxt.conceptList.Append.code := 'code';
  Context.commit('');
  tvCodes.RootNodeCount := 0;
  tvCodes.RootNodeCount := ctxt.conceptList.Count;
end;


procedure TForm5.btnDeleteCodeClick(Sender: TObject);
var
  pr : PTreeDataPointer;
  ctxt : TFhirValueSetComposeInclude;
begin
  pr := tvStructure.GetNodeData(tvStructure.FocusedNode);
  ctxt := TFhirValueSetComposeInclude(pr.obj);
  ctxt.conceptList.DeleteByIndex(tvCodes.FocusedNode.Index);
  Context.commit('');
  tvCodes.RootNodeCount := 0;
  tvCodes.RootNodeCount := ctxt.conceptList.Count;
end;

procedure TForm5.btnCodesDownClick(Sender: TObject);
var
  pr : PTreeDataPointer;
  ctxt : TFhirValueSetComposeInclude;
begin
  pr := tvStructure.GetNodeData(tvStructure.FocusedNode);
  ctxt := TFhirValueSetComposeInclude(pr.obj);
  if (tvCodes.FocusedNode <> nil) and (tvCodes.FocusedNode.Index < ctxt.conceptList.count - 1) then
  begin
    ctxt.conceptList.Exchange(tvCodes.FocusedNode.Index, tvCodes.FocusedNode.Index + 1);
    Context.commit('');
    tvCodes.RootNodeCount := 0;
    tvCodes.RootNodeCount := ctxt.conceptList.Count;
  end
  else
    MessageBeep(MB_ICONEXCLAMATION);
end;

procedure TForm5.btnCodesUpClick(Sender: TObject);
var
  pr : PTreeDataPointer;
  ctxt : TFhirValueSetComposeInclude;
begin
  if (tvCodes.FocusedNode <> nil) and (tvCodes.FocusedNode.Index > 0) then
  begin
    pr := tvStructure.GetNodeData(tvStructure.FocusedNode);
    ctxt := TFhirValueSetComposeInclude(pr.obj);
    ctxt.conceptList.Exchange(tvCodes.FocusedNode.Index - 1, tvCodes.FocusedNode.Index);
    Context.commit('');
    tvCodes.RootNodeCount := 0;
    tvCodes.RootNodeCount := ctxt.conceptList.Count;
  end
  else
    MessageBeep(MB_ICONEXCLAMATION);
end;

procedure TForm5.tvCodesCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
var
  pr : PTreeDataPointer;
  ctxt : TFhirValueSetComposeInclude;
  p : PTreeDataPointer;
  code : TFhirCode;
  s : String;
begin
  pr := tvStructure.GetNodeData(tvStructure.FocusedNode);
  ctxt := TFhirValueSetComposeInclude(pr.obj);
  p := tvCodes.GetNodeData(Node);
  code := TFhirCode(p.obj);
  if Column = 0 then
    EditLink := TVirtualStringTreeComboBox.create(EditValue(code.value), false, Context.GetList, ctxt.system)
  else if Column = 1 then
    EditLink := TVirtualStringTreeComboBox.create(EditValue(code.getExtensionString('http://hl7.org/fhir/Profile/tools-extensions#display')), false, Context.GetList, ctxt.system+'#'+code.value)
  else // comments
    EditLink := TVirtualStringTreeEdit.Create(EditValue(code.getExtensionString('http://hl7.org/fhir/Profile/tools-extensions#comment')), FFirstChar <> '');
  FFirstChar := '';
end;

procedure TForm5.tvCodesDrawText(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; const Text: string; const CellRect: TRect; var DefaultDraw: Boolean);
var
  p : PTreeDataPointer;
  c : TFhirCode;
begin
  p := Sender.GetNodeData(Node);
  c := TFhirCode(p.obj);
  if (Column = 1) and (c.getExtensionString('http://hl7.org/fhir/Profile/tools-extensions#display') = '') then
  begin
    TargetCanvas.Font.Color := clGray;
    TargetCanvas.Font.Style := [fsItalic];
  end
  else
  begin
    TargetCanvas.Font.Color := clBlack;
    TargetCanvas.Font.Style := [];
  end;
end;

procedure TForm5.tvCodesNewText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; NewText: string);
var
  pr : PTreeDataPointer;
  ctxt : TFhirValueSetComposeInclude;
  code : TFhirValueSetComposeIncludeConcept;
begin
  pr := tvStructure.GetNodeData(tvStructure.FocusedNode);
  ctxt := TFhirValueSetComposeInclude(pr.obj);
  code := ctxt.conceptList[node.Index];
  case Column of
    0: code.code := NewText;
    1: code.display := NewText;
    2: if NewText = '' then
         code.removeExtension('http://hl7.org/fhir/Profile/tools-extensions#comment')
       else
         code.setExtensionString('http://hl7.org/fhir/Profile/tools-extensions#comment', NewText);
  end;
  Context.commit('');
end;



// -----------------------------------------------------------------------------

procedure TForm5.tvFiltersEnter(Sender: TObject);
begin
  FOnCheckButtons := filtersCheckButtons;
  tbInsert.OnClick := btnAddFilterClick;
  tbDelete.OnClick := btnDeleteFilterClick;
  tbUp.OnClick := btnFiltersUpClick;
  tbDown.OnClick := btnFiltersDownClick;
  miTvInsert.OnClick := tbInsert.OnClick;
  miTvDelete.OnClick := tbDelete.OnClick;
  miTvUp.OnClick := tbUp.OnClick;
  miTvDown.OnClick := tbDown.OnClick;
  filtersCheckButtons(self);
end;

procedure TForm5.tvFiltersExit(Sender: TObject);
begin
  tbInsert.OnClick := nil;
  tbDelete.OnClick := nil;
  tbUp.OnClick := nil;
  tbDown.OnClick := nil;
  tbIn.OnClick := nil;
  tbOut.OnClick := nil;
  miTvInsert.OnClick := tbInsert.OnClick;
  miTvDelete.OnClick := tbDelete.OnClick;
  miTvUp.OnClick := tbUp.OnClick;
  miTvDown.OnClick := tbDown.OnClick;
  miTvIn.OnClick := tbIn.OnClick;
  miTvOut.OnClick := tbOut.OnClick;
  FOnCheckButtons := noButtons;
  FOnCheckButtons(self);
end;

procedure TForm5.filtersCheckButtons(sender : TObject);
var
  p : PTreeDataPointer;
begin
  tbInsert.Enabled := true; // never any reason not to
  tbDelete.Enabled := tvFilters.FocusedNode <> nil;
  tbUp.Enabled := false;
  tbDown.Enabled := false;
  if tvFilters.FocusedNode <> nil then
  begin
    tbUp.Enabled := tvFilters.FocusedNode.Index > 0;
    tbDown.Enabled := tvFilters.FocusedNode.Index < tvFilters.FocusedNode.Parent.ChildCount - 1;
  end;
  tbIn.Enabled := False;
  tbOut.Enabled := False;

  miTvInsert.Enabled := tbInsert.Enabled;
  miTvDelete.Enabled := tbDelete.Enabled;
  miTvUp.Enabled := tbUp.Enabled;
  miTvDown.Enabled := tbDown.Enabled;
  miTvIn.Enabled := tbIn.Enabled;
  miTvOut.Enabled := tbOut.Enabled;
end;


procedure TForm5.tvFiltersFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
begin
  FOnCheckButtons(self);
end;

procedure TForm5.tvFiltersInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  pr : PTreeDataPointer;
  p : PTreeDataPointer;
  ctxt : TFhirValueSetComposeInclude;
begin
  pr := tvStructure.GetNodeData(tvStructure.FocusedNode);
  ctxt := TFhirValueSetComposeInclude(pr.obj);
  p := tvCodes.GetNodeData(Node);
  p.obj := ctxt.filterList[Node.Index];
end;


procedure TForm5.tvFiltersKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if CharInSet(AnsiChar(Key), ['A'..'Z', '0'..'9']) then
  begin
    if ssShift in shift then
      FFirstChar := AnsiChar(Key)
    else
      FFirstChar := lowercase(AnsiChar(Key));
    tvFilters.EditNode(tvFilters.FocusedNode, tvFilters.FocusedColumn);
  end;
end;

procedure TForm5.tvFiltersGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  p : PTreeDataPointer;
  filter : TFhirValueSetComposeIncludeFilter;
begin
  p := tvFilters.GetNodeData(Node);
  filter := TFhirValueSetComposeIncludeFilter(p.obj);
  case Column of
    0: CellText := filter.property_;
    1: CellText := CODES_TFhirFilterOperator[filter.op];
    2: CellText := filter.value;
  end;
end;

procedure TForm5.tvFiltersCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
var
  pr : PTreeDataPointer;
  ctxt : TFhirValueSetComposeInclude;
  p : PTreeDataPointer;
  filter : TFhirValueSetComposeIncludeFilter;
  s : String;
begin
  pr := tvStructure.GetNodeData(tvStructure.FocusedNode);
  ctxt := TFhirValueSetComposeInclude(pr.obj);
  p := tvFilters.GetNodeData(Node);
  filter := TFhirValueSetComposeIncludeFilter(p.obj);
  if Column = 0 then
    EditLink := TVirtualStringTreeComboBox.create(EditValue(filter.property_), false, Context.GetList, ValueSetEditorCore.ExpressionProperty+'#'+ctxt.system)
  else if Column = 1 then
    EditLink := TVirtualStringTreeComboBox.create(CODES_TFhirFilterOperator[filter.op], true, Context.GetList, 'http://hl7.org/fhir/filter-operator')
  else // value - just a plain string editor
    EditLink := TVirtualStringTreeEdit.Create(EditValue(filter.value), FFirstChar <> '');
  FFirstChar := '';
end;


procedure TForm5.btnAddFilterClick(Sender: TObject);
var
  pr : PTreeDataPointer;
  ctxt : TFhirValueSetComposeInclude;
begin
  pr := tvStructure.GetNodeData(tvStructure.FocusedNode);
  ctxt := TFhirValueSetComposeInclude(pr.obj);
  ctxt.filterList.Append.op := FilterOperatorEqual;
  Context.commit('');
  tvFilters.RootNodeCount := 0;
  tvFilters.RootNodeCount := ctxt.FilterList.Count;
end;

procedure TForm5.btnDeleteFilterClick(Sender: TObject);
var
  pr : PTreeDataPointer;
  ctxt : TFhirValueSetComposeInclude;
begin
  pr := tvStructure.GetNodeData(tvStructure.FocusedNode);
  ctxt := TFhirValueSetComposeInclude(pr.obj);
  ctxt.FilterList.DeleteByIndex(tvFilters.FocusedNode.Index);
  Context.commit('');
  tvFilters.RootNodeCount := 0;
  tvFilters.RootNodeCount := ctxt.FilterList.Count;
end;

procedure TForm5.btnFiltersUpClick(Sender: TObject);
var
  pr : PTreeDataPointer;
  ctxt : TFhirValueSetComposeInclude;
begin
  if (tvFilters.FocusedNode <> nil) and (tvFilters.FocusedNode.Index > 0) then
  begin
    pr := tvStructure.GetNodeData(tvStructure.FocusedNode);
    ctxt := TFhirValueSetComposeInclude(pr.obj);
    ctxt.FilterList.Exchange(tvFilters.FocusedNode.Index - 1, tvFilters.FocusedNode.Index);
    Context.commit('');
    tvFilters.RootNodeCount := 0;
    tvFilters.RootNodeCount := ctxt.FilterList.Count;
  end
  else
    MessageBeep(MB_ICONEXCLAMATION);
end;

procedure TForm5.btnFiltersDownClick(Sender: TObject);
var
  pr : PTreeDataPointer;
  ctxt : TFhirValueSetComposeInclude;
begin
  pr := tvStructure.GetNodeData(tvStructure.FocusedNode);
  ctxt := TFhirValueSetComposeInclude(pr.obj);
  if (tvFilters.FocusedNode <> nil) and (tvFilters.FocusedNode.Index < ctxt.FilterList.count - 1) then
  begin
    ctxt.FilterList.Exchange(tvFilters.FocusedNode.Index, tvFilters.FocusedNode.Index + 1);
    Context.commit('');
    tvFilters.RootNodeCount := 0;
    tvFilters.RootNodeCount := ctxt.FilterList.Count;
  end
  else
    MessageBeep(MB_ICONEXCLAMATION);
end;


procedure TForm5.tvFiltersNewText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; NewText: string);
var
  pr : PTreeDataPointer;
  ctxt : TFhirValueSetComposeInclude;
  filter : TFhirValueSetComposeIncludeFilter;
begin
  pr := tvStructure.GetNodeData(tvStructure.FocusedNode);
  ctxt := TFhirValueSetComposeInclude(pr.obj);
  filter := ctxt.filterList[node.Index];
  case Column of
    0: filter.property_ := NewText;
    1: filter.op := TFhirFilterOperator(Max(0, StringArrayIndexOf(CODES_TFhirFilterOperator, NewText)));
    2: filter.value := NewText;
  end;
  Context.commit('');
end;

// expansion--------------

procedure TForm5.btnEditCodesClick(Sender: TObject);
begin
  PageControl1.ActivePage := tabDefined;
end;

procedure TForm5.Button2Click(Sender: TObject);
begin
  lblExpansion.Caption := Context.Expand(edtFilter.Text);
  tvExpansion.RootNodeCount := 0;
  tvExpansion.RootNodeCount := Max(1, Context.Expansion.containsList.Count);
end;


procedure TForm5.btnNewImportClick(Sender: TObject);
var
  n : PVirtualNode;
begin
  n := tvStructure.RootNode.FirstChild;
  n := n.NextSibling.NextSibling;
  tvStructure.FocusedNode := n;
  btnAddRuleClick(self);
end;

procedure TForm5.btnNewIncludeClick(Sender: TObject);
var
  n : PVirtualNode;
begin
  n := tvStructure.RootNode.FirstChild;
  n := n.NextSibling.NextSibling.NextSibling;
  tvStructure.FocusedNode := n;
  btnAddRuleClick(self);
end;

procedure TForm5.tvExpansionInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  list : TFhirValueSetExpansionContainsList;
  pp, p : PTreeDataPointer;
begin
  if parentNode = nil then
    list := Context.Expansion.containsList
  else
  begin
    pp := tvExpansion.GetNodeData(parentNode);
    list := TFhirValueSetExpansionContains(pp.obj).containsList;
  end;
  p := tvExpansion.GetNodeData(Node);
  if Node.Index < list.Count then
  begin
    p.obj := list[Node.Index];
    if list[node.Index].containsList.Count > 0 then
       InitialStates := [ivsHasChildren];
  end;
end;

procedure TForm5.tvExpansionInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  p : PTreeDataPointer;
  c : TFhirValueSetExpansionContains;
begin
  p := tvExpansion.GetNodeData(node);
  c := TFhirValueSetExpansionContains(p.obj);
  if (c <> nil) then
    ChildCount := c.containsList.Count;
end;

procedure TForm5.tvExpansionGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  p : PTreeDataPointer;
  c : TFhirValueSetExpansionContains;
begin
  p := tvExpansion.GetNodeData(Node);
  c := TFhirValueSetExpansionContains(p.obj);
  if (c <> nil) then
    case Column of
      0: CellText := c.system;
      1: CellText := c.code;
      2: CellText := c.display;
    end
  else if Column = 0 then
    CellText := '(no entries)'
  else
    CellText := '';
end;

procedure TForm5.tvExpansionCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  c1, c2 : TFhirValueSetExpansionContains;
begin
  c1 := TFhirValueSetExpansionContains(PTreeDataPointer(tvExpansion.GetNodeData(node1)).obj);
  c2 := TFhirValueSetExpansionContains(PTreeDataPointer(tvExpansion.GetNodeData(node2)).obj);
  case column of
    0 : result := CompareText(c1.system, c2.system);
    1 : result := CompareText(c1.code, c2.code);
    2 : result := CompareText(c1.display, c2.display);
  end;
end;

procedure TForm5.tvPreviewCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  c1, c2 : TFhirValueSetExpansionContains;
begin
  c1 := TFhirValueSetExpansionContains(PTreeDataPointer(tvPreview.GetNodeData(node1)).obj);
  c2 := TFhirValueSetExpansionContains(PTreeDataPointer(tvPreview.GetNodeData(node2)).obj);
  case column of
    0 : result := CompareText(c1.system, c2.system);
    1 : result := CompareText(c1.code, c2.code);
    2 : result := CompareText(c1.display, c2.display);
  end;
end;

procedure TForm5.tvPreviewGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  p : PTreeDataPointer;
  c : TFhirValueSetExpansionContains;
begin
  p := tvPreview.GetNodeData(Node);
  c := TFhirValueSetExpansionContains(p.obj);
  if (c <> nil) then
    case Column of
      0: CellText := c.system;
      1: CellText := c.code;
      2: CellText := c.display;
    end
  else if Column = 0 then
    CellText := '(no entries)'
  else
    CellText := '';
end;

procedure TForm5.tvPreviewInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  p : PTreeDataPointer;
  c : TFhirValueSetExpansionContains;
begin
  p := tvPreview.GetNodeData(node);
  c := TFhirValueSetExpansionContains(p.obj);
  if (c <> nil) then
    ChildCount := c.containsList.Count;
end;

procedure TForm5.tvPreviewInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
var
  list : TFhirValueSetExpansionContainsList;
  pp, p : PTreeDataPointer;
begin
  if parentNode = nil then
    list := Context.Preview.containsList
  else
  begin
    pp := tvPreview.GetNodeData(parentNode);
    list := TFhirValueSetExpansionContains(pp.obj).containsList;
  end;
  p := tvPreview.GetNodeData(Node);
  if Node.Index < list.Count then
  begin
    p.obj := list[Node.Index];
    if list[node.Index].containsList.Count > 0 then
       InitialStates := [ivsHasChildren];
  end;
end;




end.
