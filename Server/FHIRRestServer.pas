Unit FHIRRestServer;

{
Copyright (c) 2001-2013, Health Intersections Pty Ltd (http://www.healthintersections.com.au)
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of HL7 nor the names of its contributors may be used to
   endorse or promote products derived from this software without specific
   prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
}

Interface

Uses
  SysUtils, Classes, IniFiles, ActiveX, AltovaXMLLib_TLB, System.Generics.Collections, IdSoapMsXml, ComObj,

  EncodeSupport, GuidSupport, DateSupport, BytesSupport, StringSupport,

  AdvBuffers, AdvObjectLists, AdvStringMatches, AdvZipParts, AdvZipReaders, AdvVCLStreams, AdvMemories, AdvIntegerObjectMatches,

  kCritSct, ParseMap, TextUtilities, KDBManager, HTMLPublisher, KDBDialects, MsXmlParser,
  DCPsha256, AdvJSON, libeay32,

  IdMultipartFormData, IdHeaderList, IdCustomHTTPServer, IdHTTPServer,
  IdTCPServer, IdContext, IdSSLOpenSSL, IdHTTP, IdSoapMime, IdCookie,
  IdZLibCompressorBase, IdCompressorZLib, IdZlib, IdSSLOpenSSLHeaders, IdGlobalProtocols,

  TerminologyServer, SnomedServices, SnomedPublisher, SnomedExpressions, LoincServices, LoincPublisher,
  TerminologyWebServer, AuthServer,

  FHIRTypes, fhirresources, fhirparser, fhircomponents, fhirconstants,
  fhirbase, fhirparserbase, fhirtags, fhirsupport, fhirAtomFeed, FHIRLang, FHIROperation, FHIRDataStore, FHIRUtilities, FHIRSecurity,
  QuestionnaireBuilder, FHIRClient, SCIMServer;

Type
  ERestfulAuthenticationNeeded = class (ERestfulException)
  private
    FMsg : String;
  public
    Constructor Create(Const sSender, sMethod, sReason, sMsg : String; aStatus : word); Overload; Virtual;
    Property Msg : String read FMsg;
  end;

  TFhirWebServer = class;

  TFhirServerMaintenanceThread = class (TThread)
  private
    FServer : TFhirWebServer;
    FLastSweep : TDateTime;
  protected
    procedure Execute; override;
  public
    constructor create(server : TFHIRWebServer);
  end;

  TFhirWebServer = Class(TAdvObject)
  Private
    FIni : TIniFile;
    FLock : TCriticalSection;
    FLastTrack : integer;
    FTracks : TDictionary<String, String>;

    FPort : Integer;
    FSSLPort : Integer;
    FCertFile : String;
    FSSLPassword : String;
//    FBaseURL : String;
//    FProxy : String;
    FBasePath : String;
    FSecurePath : String;
    FHost : String;
    FSpecPath : String;
    FAltPath : String;
    FName : String;
    FPlainServer : TIdHTTPServer;
    FSSLServer : TIdHTTPServer;
    FIOHandler: TIdServerIOHandlerSSLOpenSSL;
    FOwnerName : String;
    FAdminEmail : String;
    FSCIMServer : TSCIMServer;

    FClientCount : Integer;

    FFhirStore : TFHIRDataStore;
    FFacebookLike : boolean;
    FTerminologyWebServer : TTerminologyWebServer;
    FThread : TFhirServerMaintenanceThread;
    FActive : boolean;
    FAuthServer : TAuth2Server;

    carry : TAdvZipReader;
    carryName : String;

    function OAuthPath(secure : boolean):String;
    procedure PopulateConformanceAuth(rest: TFhirConformanceRest);
    procedure PopulateConformance(sender : TObject; conf : TFhirConformance);

    function BuildCompartmentList(session : TFHIRSession) : String;

    function GetResource(session : TFhirSession; rtype : TFhirResourceType; lang, id, ver, op : String) : TFhirResource;
    function FindResource(session : TFhirSession; rtype : TFhirResourceType; lang, params : String; var id : String) : TFhirResource;
    function LookupReference(context : TFHIRRequest; id : String) : TResourceWithReference;
    function transform1(resource : TFhirResource; lang, xslt : String; saveOnly : boolean) : string;
    function HandleWebUIRequest(request : TFHIRRequest; response : TFHIRResponse; secure : boolean) : TDateTime;
    function HandleWebQuestionnaire(request : TFHIRRequest; response : TFHIRResponse) : TDateTime;
    function HandleWebQuestionnaireInstance(request : TFHIRRequest; response : TFHIRResponse) : TDateTime;
    function HandleWebEdit(request : TFHIRRequest; response : TFHIRResponse) : TDateTime;
    function HandleWebPost(request : TFHIRRequest; response : TFHIRResponse) : TDateTime;
    function HandleWebProfile(request: TFHIRRequest; response: TFHIRResponse) : TDateTime;
    function HandleWebPatient(request: TFHIRRequest; response: TFHIRResponse; secure : boolean) : TDateTime;
    function HandleWebCreate(request: TFHIRRequest; response: TFHIRResponse) : TDateTime;

    function SpecFile(path : String) : String;
    function AltFile(path : String) : String;
    Procedure ReturnSpecFile(response : TIdHTTPResponseInfo; stated, path : String);
    Procedure ReturnProcessedFile(response : TIdHTTPResponseInfo; session : TFhirSession; named, path : String; secure : boolean; variables: TDictionary<String, String> = nil);
    Procedure ReadTags(Headers: TIdHeaderList; Request : TFHIRRequest); overload;
    Procedure ReadTags(header : String; Request : TFHIRRequest); overload;
    function CheckSessionOK(session : TFhirSession; ip : string) : Boolean;
    Function BuildFhirHomePage(comps, lang, host, sBaseURL : String; session : TFhirSession; secure : boolean): String;
    Function BuildFhirAuthenticationPage(lang, host, path, msg : String; secure : boolean) : String;
    Function BuildFhirUploadPage(lang, host, sBaseURL : String; aType : TFHIRResourceType; session : TFhirSession) : String;
    Procedure CreatePostStream(AContext: TIdContext; AHeaders: TIdHeaderList; var VPostStream: TStream);
    Procedure ParseAuthenticationHeader(AContext: TIdContext; const AAuthType, AAuthData: String; var VUsername, VPassword: String; var VHandled: Boolean);
    Procedure ProcessScimRequest(AContext: TIdContext; request: TIdHTTPRequestInfo; response: TIdHTTPResponseInfo);
    function MarkEntry(AContext: TIdContext; request: TIdHTTPRequestInfo; response: TIdHTTPResponseInfo) : integer;
    procedure MarkExit(track : integer);
    Procedure PlainRequest(AContext: TIdContext; request: TIdHTTPRequestInfo; response: TIdHTTPResponseInfo);
    Procedure SecureRequest(AContext: TIdContext; request: TIdHTTPRequestInfo; response: TIdHTTPResponseInfo);
    Procedure HandleRequest(AContext: TIdContext; request: TIdHTTPRequestInfo; response: TIdHTTPResponseInfo; ssl, secure : Boolean; path : String);
    Procedure HandleDiscoveryRedirect(AContext: TIdContext; request: TIdHTTPRequestInfo; response: TIdHTTPResponseInfo);
    Procedure ProcessOutput(oRequest : TFHIRRequest; oResponse : TFHIRResponse; response: TIdHTTPResponseInfo; relativeReferenceAdjustment : integer; pretty, gzip : boolean);
    function extractFileData(form : TIdSoapMimeMessage; const name: String; var sContentType : String): TStream;
    Procedure StartServer(active : boolean);
    Procedure StopServer;
    Function ProcessZip(lang : String; oStream : TStream; name, base : String; init : boolean; ini : TIniFile; var cursor : integer) : TFHIRAtomFeed;
    procedure SSLPassword(var Password: String);
    procedure SendError(response: TIdHTTPResponseInfo; status : word; format : TFHIRFormat; lang, message, url : String; session : TFhirSession; addLogins : boolean; path : String; relativeReferenceAdjustment : integer; code : String = '');
    Procedure ProcessRequest(request : TFHIRRequest; response : TFHIRResponse; upload : Boolean);
    function BuildRequest(lang, sBaseUrl, sHost, sOrigin, sClient, sContentLocation, sCommand, sResource, sContentType, sContentAccept, sContentEncoding, sCookie, provenance: String; oPostStream: TStream; oResponse: TFHIRResponse;     var aFormat: TFHIRFormat; var redirect: boolean; form: TIdSoapMimeMessage; bAuth, secure : Boolean; out relativeReferenceAdjustment : integer; var pretty : boolean): TFHIRRequest;
    procedure DoConnect(AContext: TIdContext);
    procedure DoDisconnect(AContext: TIdContext);
    Function WebDesc : String;
    function EndPointDesc(secure : boolean) : String;
    procedure GetWebUILink(resource : TFhirResource; base, statedType, id, ver : String; var link, text : String);
    function loadMultipartForm(const request: TStream; const contentType : String): TIdSoapMimeMessage;
    function processProvenanceHeader(header, lang : String) : TFhirProvenance;
  Public
    Constructor Create(ini : TFileName; db : TKDBManager; Name : String; terminologyServer : TTerminologyServer);
    Destructor Destroy; Override;

    Procedure Start(active : boolean);
    Procedure Stop;
    Procedure Transaction(stream : TStream; init: boolean; name, base : String; ini : TIniFile);

    function dump : String;

    Property DataStore : TFHIRDataStore read FFhirStore;
  End;

Implementation


Uses
  Windows, Registry,

  AdvExceptions, SystemService,

  FileSupport,
  FaceBookSupport;

Function GetMimeTypeForExt(AExt: String): String;
Var
  fReg: TRegistry;
Begin
  AExt := lowercase(AExt);
  if (AExt = '.css') Then
    result := 'text/css'
  Else if AExt = '.ico' Then
    result := 'image/x-icon'
  Else if AExt = '.png' Then
    result := 'image/png'
  Else if AExt = '.gif' Then
    result := 'image/gif'
  Else if AExt = '.jpg' Then
    result := 'image/jpeg'
  Else if AExt = '.mpg' Then
    result := 'video/mpeg'
  Else if AExt = '.js' Then
    result := 'text/javascript'
  Else
  Begin
    Try
      fReg := TRegistry.Create;
      Try
        fReg.RootKey := HKEY_LOCAL_MACHINE;
        fReg.OpenKeyReadOnly('Software\Classes\' + AExt);
        Result := freg.ReadString('Content Type');
        fReg.CloseKey;
      Finally
        freg.Free;
      End;
    Except
    End;
  End;
  If Result = '' Then
    Result := 'application/octet-stream';
End;

{ TFhirWebServer }

Function ProcessPath(base, path : String): string;
var
  s : String;
begin
  base := base.Substring(0, base.Length-1);
  if path.StartsWith('..\') then
  begin
    s := base;
    while path.StartsWith('..\') do
    begin
      path := path.Substring(3);
      s := ExtractFilePath(s);
      s := s.Substring(0, s.Length-1);
    end;
    result := IncludeTrailingPathDelimiter(s)+IncludeTrailingPathDelimiter(path);
  end
  else
    result := IncludeTrailingPathDelimiter(path);
end;

Constructor TFhirWebServer.Create(ini : TFileName; db : TKDBManager; Name : String; terminologyServer : TTerminologyServer);
var
  s : String;
Begin
  Inherited Create;
  FLock := TCriticalSection.Create('fhir-rest');
  FName := Name;
  FIni := TIniFile.Create(ini);
  FHost := FIni.ReadString('web', 'host', '');
  FTracks := TDictionary<String, String>.create();

  FSpecPath := ProcessPath(ExtractFilePath(ini), FIni.ReadString('fhir', 'source', ''));
  FAltPath := ProcessPath(ExtractFilePath(ini), FIni.ReadString('fhir', 'other', ''));
  writelnt('Load User Sub-system');
  FSCIMServer := TSCIMServer.Create(db, FAltPath, FIni.ReadString('scim', 'salt', ''), Fhost, FIni.ReadString('scim', 'default-rights', ''), false);
  FSCIMServer.OnProcessFile := ReturnProcessedFile;

  writelnt('Load & Cache Store: ');
  FOwnerName := Fini.readString('admin', 'ownername', '');
  if FOwnerName = '' then
    FOwnerName := 'Health Intersections';
  FAdminEmail := Fini.readString('admin', 'email', '');
  if FAdminEmail = '' then
    raise Exception.Create('Ad admin email is required');

  // Base Web server configuration
  FBasePath := FIni.ReadString('web', 'base', '');
  FSecurePath := FIni.ReadString('web', 'secure', '');
  FPort := FIni.ReadInteger('web', 'http', 0);
  FSSLPort := FIni.ReadInteger('web', 'https', 0);
  FCertFile := FIni.ReadString('web', 'certname', '');
  FSSLPassword := FIni.ReadString('web', 'certpword', '');
  FFacebookLike := FIni.ReadString('facebook.com', 'like', '') = '1';

  if FIni.ReadString('web', 'insecure', '') = 'conformance' then
    nonSecureTypes := [frtConformance, frtStructureDefinition, frtValueSet, frtConceptMap, frtDataElement, frtOperationDefinition, frtSearchParameter, frtNamingSystem]
  else if FIni.ReadString('web', 'insecure', '') = 'conformance+patient' then
    nonSecureTypes := [frtConformance, frtStructureDefinition, frtValueSet, frtConceptMap, frtDataElement, frtOperationDefinition, frtSearchParameter, frtNamingSystem, frtPatient]
  else
    nonSecureTypes := ALL_RESOURCE_TYPES;

  FTerminologyWebServer := TTerminologyWebServer.create(terminologyServer.Link, FBasePath+'/', FAltPath, ReturnProcessedFile);

  FFhirStore := TFHIRDataStore.Create(db, FSpecPath, FAltPath, terminologyServer, FINi, FSCIMServer.Link);
  FFhirStore.ownername := FOwnerName;
  FFhirStore.Validate := FIni.ReadBool('fhir', 'validate', true);
  if FIni.ReadString('web', 'host', '') <> '' then
  begin
    if FIni.ReadString('web', 'base', '') <> '' then
      s := FIni.ReadString('web', 'base', '')
    else
      s := FIni.ReadString('web', 'secure', '');
  end;
  writelnt(inttostr(FFhirStore.TotalResourceCount)+' resources');
  FFhirStore.FormalURLPlain := 'http://'+FIni.ReadString('web', 'host', '')+':'+inttostr(FPort);
  FFhirStore.FormalURLSecure := 'https://'+FIni.ReadString('web', 'host', '')+':'+inttostr(FSSLPort);
  FFhirStore.FormalURLPlainOpen := 'http://'+FIni.ReadString('web', 'host', '')+':'+inttostr(FPort)+ FBasePath;
  FFhirStore.FormalURLSecureOpen := 'https://'+FIni.ReadString('web', 'host', '')+':'+inttostr(FSSLPort) + FBasePath;
  FFhirStore.FormalURLSecureClosed := 'https://'+FIni.ReadString('web', 'host', '')+':'+inttostr(FSSLPort) + FSecurePath;


  if FIni.readString('web', 'clients', '') = '' then
    raise Exception.Create('No Authorization file found');
  FAuthServer := TAuth2Server.Create(FIni.readString('web', 'clients', ''), FAltPath, FHost, inttostr(FSSLPort), FSCIMServer.Link);
  FAuthServer.FHIRStore := FFhirStore.Link;
  FAuthServer.OnProcessFile := ReturnProcessedFile;
  FAuthServer.SSLCert := FCertFile;
  FAuthServer.SSLPassword := FSSLPassword;
  FAuthServer.AdminEmail := FAdminEmail;
  FAuthServer.EndPoint := OAuthPath(true);


  if (FPort <> 0) and (FSSLPort <> 0) then
    writelnt('Web Server: http = '+inttostr(FPort)+', https = '+inttostr(FSSLPort))
  else if (FPort <> 0) then
    writelnt('Web Server: http = '+inttostr(FPort))
  else if (FSSLPort <> 0) then
    writelnt('Web Server: https = '+inttostr(FSSLPort))
  else
    writelnt('Web Server not configued');

  if (FBasePath <> '') and (FSecurePath <> '') then
    writelnt(' ...paths: open = '+FBasePath+', secure = '+FSecurePath)
  else if (FPort <> 0) then
    writelnt(' ...paths: open = '+FBasePath)
  else if (FSSLPort <> 0) then
    writelnt(' ...paths: secure = '+FSecurePath)
  else
    writelnt(' ...paths: <none>');

//  FAuthRequired := FIni.ReadString('fhir', 'oauth-secure', '') = '1';
//  FAppSecrets := FIni.ReadString('fhir', 'oauth-secrets', '');
End;

Destructor TFhirWebServer.Destroy;
Begin
  carry.Free;
  FSCIMServer.Free;
  FTerminologyWebServer.free;
  FIni.Free;
  FAuthServer.Free;
  if FFhirStore <> nil then
  begin
    FFhirStore.CloseAll;
    FFhirStore.Free;
  end;
  FTracks.Free;
  FLock.Free;
  Inherited;
End;

procedure TFhirWebServer.DoConnect(AContext: TIdContext);
begin
  CoInitialize(nil);
  FLock.Lock;
  try
    inc(FClientCount);
  finally
    FLock.Unlock;
  end;
end;

procedure TFhirWebServer.DoDisconnect(AContext: TIdContext);
begin
  FLock.Lock;
  try
    dec(FClientCount);
  finally
    FLock.Unlock;
  end;
  CoUninitialize;
end;

function TFhirWebServer.dump : String;
var
  s : String;
begin
  result := 'Current Web Requests: '+#13#10;
  FLock.Lock;
  try
    for s in FTracks.Keys do
      result := result + FTracks[s]+#13#10;
  finally
    FLock.Unlock;
  end;
end;

function port(port, default : integer): String;
begin
  if (port = default) then
    result := ''
  else
    result := ':'+inttostr(port);
end;

function TFhirWebServer.EndPointDesc(secure : boolean): String;
begin
  result := '';
  if (secure) then
  begin
    if FBasePath <> '' then
      result := result + ' <li><a href="http://'+FHost+port(FPort, 80)+FBasePath+'">Unsecured access at '+FBasePath+'</a> - direct access with no security considerations</li>'#13#10;
    if FSecurePath <> '' then
      result := result + ' <li><a href="'+FSecurePath+'">Secured access at '+FSecurePath+'</a> - Login required using <a href="http://fhir-docs.smarthealthit.org/argonaut-dev/authorization/">SMART-ON-FHIR</a></li>'#13#10;
  end
  else
  begin
    if FBasePath <> '' then
      result := result + ' <li><a href="'+FBasePath+'">Unsecured access at '+FBasePath+'</a> - direct access with no security considerations</li>'#13#10;
    if FSecurePath <> '' then
      result := result + ' <li><a href="https://'+FHost+port(FSSLPort, 443)+FSecurePath+'">Secured access at '+FSecurePath+'</a> - Login required using <a href="http://fhir-docs.smarthealthit.org/argonaut-dev/authorization/">SMART-ON-FHIR</a></li>'#13#10;
  end;
end;

Procedure TFhirWebServer.Start(active : boolean);
Begin
  FActive := active;
  StartServer(active);
  if (active) then
    FThread := TFhirServerMaintenanceThread.create(self);
End;

Procedure TFhirWebServer.Stop;
Begin
  if FThread <> nil then
    FThread.Terminate;
  StopServer;
End;

Procedure TFhirWebServer.StartServer(active : boolean);
Begin
  if FPort > 0 then
  begin
    FPlainServer := TIdHTTPServer.Create(Nil);
    FPlainServer.ServerSoftware := 'Health Intersections FHIR Server';
    FPlainServer.ParseParams := False;
    FPlainServer.DefaultPort := FPort;
    FPlainServer.KeepAlive := False;
    FPlainServer.OnCreatePostStream := CreatePostStream;
    FPlainServer.OnCommandGet := PlainRequest;
    FPlainServer.OnCommandOther := PlainRequest;
    FPlainServer.OnConnect := DoConnect;
    FPlainServer.OnDisconnect := DoDisconnect;
    FPlainServer.Active := active;
  end;
  if FSSLPort > 0 then
  begin
    If Not FileExists(FCertFile) Then
      Raise Exception.Create('SSL Certificate "'+FCertFile+' could not be found');
    If Not FileExists(ChangeFileExt(FCertFile, '.key')) Then
      Raise Exception.Create('SSL Certificate Private Key "'+ChangeFileExt(FCertFile, '.key')+' could not be found');
    FSSLServer := TIdHTTPServer.Create(Nil);
    FSSLServer.ServerSoftware := 'Health Intersections FHIR Server';
    FSSLServer.ParseParams := False;
    FSSLServer.DefaultPort := FSSLPort;
    FSSLServer.KeepAlive := False;
    FSSLServer.OnCreatePostStream := CreatePostStream;
    FIOHandler := TIdServerIOHandlerSSLOpenSSL.Create(Nil);
    FSSLServer.IOHandler := FIOHandler;
    FIOHandler.SSLOptions.Method := sslvSSLv23;
    // SSL v3 / TLS 1 required for older versions of DotNet
    FIOHandler.SSLOptions.SSLVersions := [sslvSSLv3, sslvTLSv1, sslvTLSv1_2];
    FIOHandler.SSLOptions.CipherList := 'ALL:!SSLv2:!DES';
    FIOHandler.SSLOptions.CertFile := FCertFile;
    FIOHandler.SSLOptions.KeyFile := ChangeFileExt(FCertFile, '.key');
    FIOHandler.OnGetPassword := SSLPassword;
    FSSLServer.OnCommandGet := SecureRequest;
    FSSLServer.OnCommandOther := SecureRequest;
    FSSLServer.OnConnect := DoConnect;
    FSSLServer.OnDisconnect := DoDisconnect;
    FSSLServer.OnParseAuthentication := ParseAuthenticationHeader;
    FSSLServer.Active := active;
    LoadEAYExtensions;
  end;
end;

Procedure TFhirWebServer.StopServer;
Begin
  if FSSLServer <> nil then
  begin
    FSSLServer.Active := False;
    FreeAndNil(FSSLServer);
    FreeAndNil(FIOHandler);
    UnloadEAYExtensions;
  end;
  if FPlainServer <> nil then
  begin
    FPlainServer.Active := False;
    FreeAndNil(FPlainServer);
  end;
End;

procedure TFhirWebServer.Transaction(stream: TStream; init: boolean; name, base : String; ini : TIniFile);
var
  req : TFHIRRequest;
  resp : TFHIRResponse;
  op : TFhirOperationManager;
  cursor : integer;
begin
  if init then
  begin
    op := TFhirOperationManager.Create('en', FFhirStore.Link);
    try
      op.Connection := DataStore.DB.GetConnection('op');
      try
        op.DefineConformanceResources(FIni.ReadString('web', 'host', ''));
        op.Connection.Release;
      except
        on e:exception do
          op.Connection.Error(e);
      end;
    finally
      op.Free;
    end;
  end;

  req := TFHIRRequest.Create;
  try
    req.CommandType := fcmdTransaction;
    req.Feed := ProcessZip('en', stream, name, base, init, ini, cursor);
    req.feed.tags['duplicates'] := 'ignore';
    req.session := FFhirStore.CreateImplicitSession('service', true);
    req.session.allowAll;
    req.LoadParams('');
    req.baseUrl := FFhirStore.Bases[0];
    resp := TFHIRResponse.Create;
    try
      ProcessRequest(req, resp, true);
    finally
      resp.Free;
    end;
    if (ini <> nil) then
      if (cursor = -1) then
        ini.DeleteKey('process', 'start')
      else
        ini.WriteInteger('process', 'start', cursor);
  finally
    req.Free;
  end;

end;

function TFhirWebServer.WebDesc: String;
begin
  if (FPort = 0) then
    result := 'HTTPS is supported on Port '+inttostr(FSSLPort)+'.'
  else if FSSLPort = 0 then
    result := 'HTTP is supported on Port '+inttostr(FPort)+'.'
  else
    result := 'HTTPS is supported on Port '+inttostr(FSSLPort)+'. HTTP is supported on Port '+inttostr(FPort)+'.'
end;

Procedure TFhirWebServer.CreatePostStream(AContext: TIdContext; AHeaders: TIdHeaderList; var VPostStream: TStream);
Begin
  VPostStream := TMemoryStream.Create;
End;

Procedure CheckId(lang, id : String);
var
  i : integer;
begin

  if (Length(id) > ID_LENGTH) then
    Raise ERestfulException.Create('TFhirWebServer', 'SplitId', StringFormat(GetFhirMessage('MSG_ID_TOO_LONG', lang), [id]), HTTP_ERR_BAD_REQUEST);
  for i := 1 to length(id) do
    if not CharInSet(id[i], ['a'..'z', '0'..'9', 'A'..'Z', '.', '-']) then
      Raise ERestfulException.Create('TFhirWebServer', 'SplitId', StringFormat(GetFhirMessage('MSG_ID_INVALID', lang), [id, id[i]]), HTTP_ERR_BAD_REQUEST);
end;

procedure TFhirWebServer.ParseAuthenticationHeader(AContext: TIdContext; const AAuthType, AAuthData: String; var VUsername, VPassword: String; var VHandled: Boolean);
begin
  VHandled := AAuthType = 'Bearer';
  VUserName := AAuthType;
  VPassword := AAuthData;
end;

Procedure TFhirWebServer.PlainRequest(AContext: TIdContext; request: TIdHTTPRequestInfo; response: TIdHTTPResponseInfo);
var
  session : TFHIRSession;
  c : integer;
  check : boolean;
  track : integer;
begin
  session := nil;
  track := MarkEntry(AContext, request, response);
  try
    c := request.Cookies.GetCookieIndex(FHIR_COOKIE_NAME);
    if c > -1 then
      FFhirStore.GetSession(request.Cookies[c].CookieText.Substring(FHIR_COOKIE_NAME.Length+1), session, check); // actually, in this place, we ignore check.  we just established the session

    if FileExists(SpecFile(request.Document)) then
      ReturnSpecFile(response, request.Document, SpecFile(request.Document))
    else if FileExists(AltFile(request.Document)) then
      ReturnSpecFile(response, request.Document, AltFile(request.Document))
    else if request.Document.EndsWith('.hts') and FileExists(ChangeFileExt(AltFile(request.Document), '.html')) then
      ReturnProcessedFile(response, session, request.Document, ChangeFileExt(AltFile(request.Document), '.html'), false)
  //  else if FileExists(FAltPath+ExtractFileName(request.Document.replace('/', '\'))) then
  //    ReturnSpecFile(response, request.Document, FAltPath+ExtractFileName(request.Document.replace('/', '\')))
  //  else if FileExists(FSpecPath+ExtractFileName(request.Document.replace('/', '\'))) then
  //    ReturnSpecFile(response, request.Document, FSpecPath+ExtractFileName(request.Document.replace('/', '\')))
    else if request.document = FBasePath+'/.well-known/openid-configuration' then
      HandleDiscoveryRedirect(AContext, request, response)
    else if request.document = '/.well-known/openid-configuration' then
      FAuthServer.HandleDiscovery(AContext, request, response)
    else if request.Document.StartsWith(FBasePath, false) then
      HandleRequest(AContext, request, response, false, false, FBasePath)
    else if request.Document.StartsWith(FSecurePath, false) then
      HandleRequest(AContext, request, response, false, false, FBasePath)
    else if request.Document = '/' then
      ReturnProcessedFile(response, session, '/homepage.html', AltFile('/homepage.html'), false)
    else if FTerminologyWebServer.handlesRequest(request.Document) then
      FTerminologyWebServer.Process(AContext, request, session, response, false)
    else
    begin
      response.ResponseNo := 404;
      response.ContentText := 'Document '+request.Document+' not found';
      writelnt('miss: '+request.Document);
    end;
  finally
    MarkExit(track);
  end;
end;

procedure TFhirWebServer.PopulateConformanceAuth(rest: TFhirConformanceRest);
var
  c : TFHIRCoding;
begin
  if rest.security = nil then
    rest.security := TFhirConformanceRestSecurity.Create;
  rest.security.cors := true;
  if FAuthServer <> nil then
  begin
    c := rest.security.serviceList.Append.codingList.Append;
    c.system := 'http://hl7.org/fhir/restful-security-service';
    c.code := 'OAuth2';
    rest.security.description := 'This server implements OAuth2 for login';

    rest.security.addExtension('http://fhir-registry.smarthealthit.org/Profile/oauth-uris#oidc-discovery',
      TFhirUri.Create(ExcludeTrailingPathDelimiter(FFhirStore.FormalURLSecure)+FAuthServer.AuthPath+'/discovery'));
    rest.security.addExtension('http://fhir-registry.smarthealthit.org/Profile/oauth-uris#register',
      TFhirUri.Create('mailto:'+FAdminEmail));
    rest.security.addExtension('http://fhir-registry.smarthealthit.org/Profile/oauth-uris#authorize',
      TFhirUri.Create(ExcludeTrailingPathDelimiter(FFhirStore.FormalURLSecure)+FAuthServer.AuthPath));
    rest.security.addExtension('http://fhir-registry.smarthealthit.org/Profile/oauth-uris#token',
      TFhirUri.Create(ExcludeTrailingPathDelimiter(FFhirStore.FormalURLSecure)+FAuthServer.TokenPath));
  end;
end;

procedure TFhirWebServer.PopulateConformance(sender: TObject; conf: TFhirConformance);
var
  i : integer;
begin
  for i := 0 to conf.restList.Count - 1 do
    PopulateConformanceAuth(conf.restList[i]);



end;

function TFhirWebServer.SpecFile(path : String) : String;
begin
  if path.StartsWith('/') then
    result := FSpecPath+path.Substring(1).Replace('/', '\')
  else
    result := '';
end;

function TFhirWebServer.AltFile(path : String) : String;
begin
  if path.StartsWith('/') then
    result := FAltPath+path.Substring(1).Replace('/', '\')
  else
    result := '';
end;


Procedure TFhirWebServer.SecureRequest(AContext: TIdContext; request: TIdHTTPRequestInfo; response: TIdHTTPResponseInfo);
var
  session : TFHIRSession;
  check : boolean;
  c : integer;
  track : integer;
begin
  session := nil;
  track := MarkEntry(AContext, request, response);
  try
    c := request.Cookies.GetCookieIndex(FHIR_COOKIE_NAME);
    if c > -1 then
      FFhirStore.GetSession(request.Cookies[c].CookieText.Substring(FHIR_COOKIE_NAME.Length+1), session, check); // actually, in this place, we ignore check.  we just established the session

    if (request.CommandType = hcOption) and ((request.Document <> FBasePath) and (request.Document <> FSecurePath)) then
    begin
      response.ResponseNo := 200;
      response.ContentText := 'ok';
      response.CustomHeaders.add('Access-Control-Allow-Origin: *');
  //  response.CustomHeaders.add('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
      response.CustomHeaders.add('Access-Control-Expose-Headers: Content-Location, Location');
      response.CustomHeaders.add('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
  //  response.CustomHeaders.add('Access-Control-Expose-Headers: *');
      if request.RawHeaders.Values['Access-Control-Request-Headers'] <> '' then
        response.CustomHeaders.add('Access-Control-Allow-Headers: '+request.RawHeaders.Values['Access-Control-Request-Headers']);
    end
    else if FileExists(SpecFile(request.Document)) then
      ReturnSpecFile(response, request.Document, SpecFile(request.Document))
    else if FileExists(AltFile(request.Document)) then
      ReturnSpecFile(response, request.Document, AltFile(request.Document))
    else if request.Document.EndsWith('.hts') and FileExists(ChangeFileExt(AltFile(request.Document), '.html')) then
      ReturnProcessedFile(response, session, request.Document, ChangeFileExt(AltFile(request.Document), '.html'), true)
  //  else if FileExists(IncludeTrailingPathDelimiter(FAltPath)+request.Document) then
  //    ReturnSpecFile(response, request.Document, IncludeTrailingPathDelimiter(FAltPath)+request.Document)
  //  else if FileExists(AltFile(ExtractFileName(request.Document))) then
  //    ReturnSpecFile(response, request.Document, AltFile(ExtractFileName(request.Document)))
    else if request.document = FBasePath+'/.well-known/openid-configuration' then
      HandleDiscoveryRedirect(AContext, request, response)
    else if request.Document.StartsWith('/scim') then
      processSCIMRequest(AContext, request, response)
    else if request.document = '/.well-known/openid-configuration' then
      FAuthServer.HandleDiscovery(AContext, request, response)
  //  else if request.Document.StartsWith(FBasePath, false) then
  //    HandleRequest(AContext, request, response, true, false, FBasePath)
    else if request.Document.StartsWith(FSecurePath, false) then
      HandleRequest(AContext, request, response, true, true, FSecurePath)
    else if FTerminologyWebServer.handlesRequest(request.Document) then
      FTerminologyWebServer.Process(AContext, request, session, response, true)
    else if request.Document.StartsWith('/oauth2') then
      FAuthServer.HandleRequest(AContext, request, session, response)
    else if request.Document = '/' then
      ReturnProcessedFile(response, session, '/hompage.html', AltFile('/homepage.html'), true)
    else
    begin
      response.ResponseNo := 404;
      response.ContentText := 'Document '+request.Document+' not found';
      writelnt('miss: '+request.Document);
    end;
  finally
    markExit(track)
  end;
end;

function processIfModifiedSince(value : String) : TDateTime;
begin
  if value <> '' then
    result := GMTToLocalDateTime(value)
  else
    result := 0;
end;

function processIfMatch(value : string) : String;
begin
  if value.StartsWith('W/') then
    value := value.Substring(2);
  if value.StartsWith('"') and value.EndsWith('"') then
    result := copy(value, 2, length(value)-2)
  else
    result := value;

end;
procedure TFhirWebServer.HandleDiscoveryRedirect(AContext: TIdContext; request: TIdHTTPRequestInfo; response: TIdHTTPResponseInfo);
begin
  if FAuthServer = nil then
  begin
    response.ResponseNo := 404;
    response.ResponseText := 'Not Found';
    response.ContentText := 'This server does not support authentication';
  end
  else
  begin
    response.ResponseNo := 301;
    response.ResponseText := 'Moved Permanently';
    response.Location := FAuthServer.BasePath+'/discovery';
  end;
end;

Procedure TFhirWebServer.HandleRequest(AContext: TIdContext; request: TIdHTTPRequestInfo; response: TIdHTTPResponseInfo; ssl, secure : Boolean; path : String);
var
  sHost : string;
  oRequest : TFHIRRequest;
  oResponse : TFHIRResponse;
  sCookie : string;
  sContentType : String;
  oStream : TStream;
  sDoc : String;
  s : String;
  aFormat : TFHIRFormat;
  lang : String;
  sPath : String;
  session : TFhirSession;
  redirect : Boolean;
  form : TIdSoapMimeMessage;
  relativeReferenceAdjustment : integer;
  pretty : boolean;
  c : integer;
  domain : String;
  noErrCode : boolean;
Begin
  noErrCode := false;
  Session := nil;
  try
    if ssl then
      sHost := 'https://'+request.Host
    else
      sHost := 'http://'+request.Host;
    domain := request.Host;
    if domain.Contains(':') then
      domain := domain.Substring(0, domain.IndexOf(':'));

    lang := request.AcceptLanguage;
    s := request.ContentType;
    if pos(';', s) > 0 then
      s := copy(s, 1, pos(';', s) - 1); //only read up to the first ';'
    if SameText(s, 'application/x-www-form-urlencoded') or (request.UnparsedParams <> '') then
      sDoc := request.Document +'?'+ request.UnparsedParams
    else
      sDoc := request.Document;
    try
      sContentType := request.ContentType;

    if s.StartsWith('multipart/form-data', true) then
      form := loadMultipartForm(request.PostStream, request.ContentType)
    else
      form := nil;
    try
      if s.StartsWith('multipart/form-data', true) then
      begin
        oStream := extractFileData(form, 'file', sContentType); // though this might not return the data if we have an operation request
      end
      else if request.PostStream <> nil then
      begin
        oStream := TMemoryStream.create;
        oStream.CopyFrom(request.PostStream, request.PostStream.Size);
        oStream.Position := 0;
      end
      else
        oStream := TStringStream.Create(request.UnparsedParams);

        try
          response.CustomHeaders.add('Access-Control-Allow-Origin: *');
//          response.CustomHeaders.add('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
          response.CustomHeaders.add('Access-Control-Expose-Headers: Content-Location, Location');
          response.CustomHeaders.add('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
//          response.CustomHeaders.add('Access-Control-Expose-Headers: *');
          if request.RawHeaders.Values['Access-Control-Request-Headers'] <> '' then
            response.CustomHeaders.add('Access-Control-Allow-Headers: '+request.RawHeaders.Values['Access-Control-Request-Headers']);
          oResponse := TFHIRResponse.Create;
          Try
            if request.AuthUsername = 'Bearer' then
              sCookie := request.AuthPassword
            else
            begin
              c := request.Cookies.GetCookieIndex(FHIR_COOKIE_NAME);
              if c > -1 then
                sCookie := request.Cookies[c].CookieText.Substring(FHIR_COOKIE_NAME.Length+1);
            end;

            oRequest := BuildRequest(lang, path, sHost, request.CustomHeaders.Values['Origin'], request.RemoteIP, request.CustomHeaders.Values['content-location'],
               request.Command, sDoc, sContentType, request.Accept, request.ContentEncoding, sCookie, request.RawHeaders.Values['Provenance'], oStream, oResponse, aFormat, redirect, form, secure, ssl, relativeReferenceAdjustment, pretty);
            try
              oRequest.IfMatch := processIfMatch(request.RawHeaders.Values['If-Match']);
              oRequest.IfNoneMatch := processIfMatch(request.RawHeaders.Values['If-None-Match']);
              oRequest.IfNoneExist := request.RawHeaders.Values['If-None-Exist'];
              oRequest.IfModifiedSince := processIfModifiedSince(request.RawHeaders.Values['If-Modified-Since']);

              noErrCode := StringArrayExistsInsensitive(['yes', 'true', '1'], oRequest.Parameters.GetVar('nohttperr')) or StringArrayExistsInsensitive(['yes', 'true', '1'], oRequest.Parameters.GetVar('_nohttperr'));
              ReadTags(request.RawHeaders.Values['Category'], oRequest);
              session := oRequest.Session.Link;
              if redirect then
              begin
                if oRequest.Session <> nil then
                begin
                  FAuthServer.setCookie(response, FHIR_COOKIE_NAME, oRequest.Session.Cookie, domain, '', oRequest.Session.Expires, false);
                  response.Redirect(oRequest.Session.OriginalUrl);
                end
                else
                  response.Redirect(oRequest.baseUrl);
              end
              else if oRequest.CommandType = fcmdNull then
              begin
                response.CustomHeaders.add('Access-Control-Request-Method: GET, POST, PUT, DELETE');
              end
              else if oRequest.CommandType = fcmdUnknown then
              begin
                response.ResponseNo := 200;
                response.ContentType := 'text/html; charset=UTF-8';
                response.FreeContentStream := true;
                response.ContentStream := StringToUTF8Stream(BuildFhirHomePage(oRequest.compartments, lang, sHost, path, oRequest.Session, secure));
              end
              else if (oRequest.CommandType = fcmdUpload) and (oRequest.Resource = nil) and (oRequest.Feed = nil) Then
              begin
                response.ResponseNo := 200;
                response.ContentType := 'text/html; charset=UTF-8';
                response.FreeContentStream := true;
                response.ContentStream := StringToUTF8Stream(BuildFhirUploadPage(lang, sHost, '', oRequest.ResourceType, oRequest.Session));
              end
              else if (oRequest.CommandType = fcmdConformanceStmt) and (oRequest.ResourceType <> frtNull) then
              begin
                response.ResponseNo := 200;
                response.ContentType := 'text/html; charset=UTF-8';
  // no - just use *              response.CustomHeaders.add('Access-Control-Allow-Origin: '+request.RawHeaders.Values['Origin']);
                response.CustomHeaders.add('Access-Control-Request-Method: GET, POST, PUT, DELETE');
                response.FreeContentStream := true;
                response.ContentStream := StringToUTF8Stream('OK');
              end
              else
              begin
                try
                  if oRequest.CommandType = fcmdWebUI then
                    HandleWebUIRequest(oRequest, oResponse, secure)
                  else
                    ProcessRequest(oRequest, oResponse, false);
                except
                  on e : EAbort do
                  begin
                    if oResponse.HTTPCode < 300 then
                      raise;
                  end;
                  on e : Exception do
                    raise;
                end;
                ProcessOutput(oRequest, oResponse, response, relativeReferenceAdjustment, pretty, request.AcceptEncoding.Contains('gzip'));
  // no - just use *              if request.RawHeaders.Values['Origin'] <> '' then
  //                 response.CustomHeaders.add('Access-Control-Allow-Origin: '+request.RawHeaders.Values['Origin']);
                if oResponse.versionId <> '' then
                  response.ETag := 'W/"'+oResponse.versionId+'"';
                response.LastModified := oResponse.lastModifiedDate; // todo: timezone
                if oResponse.Categories.count > 0 then
                  response.CustomHeaders.add('Category: '+ oResponse.Categories.AsHeader);
                if oResponse.link_List.count > 0 then
                  response.CustomHeaders.add('Link: '+ oResponse.link_List.AsHeader);
                if oResponse.originalId <> '' then
                  response.CustomHeaders.add('X-Original-Location: '+oResponse.originalId);
                if oResponse.ContentLocation <> '' then
                  response.CustomHeaders.add('Content-Location: '+oResponse.ContentLocation);
                if oResponse.Location <> '' then
                  response.Location := oResponse.Location;
              end;
              if noErrCode then
                response.ResponseNo := 200;
              response.WriteContent;
            finally
              oRequest.Free;
            end;
          Finally
           oResponse.free;
          End;
        finally
          oStream.free;
        end;
      finally
        form.Free;
      end;
    except
      on e : ERestfulAuthenticationNeeded do
      begin
        if aFormat = ffXhtml then
        begin
          response.ResponseNo := 200;
          response.ContentType := 'text/html; charset=UTF-8';
          response.FreeContentStream := true;
          response.ContentStream := StringToUTF8Stream(BuildFhirAuthenticationPage(lang, sHost, sPath + sDoc, e.Msg, ssl));
        end
        else
          SendError(response, e.Status, aFormat, lang, e.Message, sPath, session, true, sPath + sDoc, relativeReferenceAdjustment);
      end;
      on e : ETooCostly do
        if noErrCode then
          SendError(response, 200, aFormat, lang, e.Message, sPath, session, false, path, relativeReferenceAdjustment, 'too-costly')
        else
          SendError(response, HTTP_ERR_BUSINESS_RULES_FAILED, aFormat, lang, e.Message, sPath, session, false, path, relativeReferenceAdjustment, 'too-costly');
      on e: ERestfulException do
        if noErrCode then
          SendError(response, 200, aFormat, lang, e.Message, sPath, session, false, path, relativeReferenceAdjustment)
        else
          SendError(response, e.Status, aFormat, lang, e.Message, sPath, session, false, path, relativeReferenceAdjustment);
      on e: Exception do
        if noErrCode then
          SendError(response, 200, aFormat, lang, e.Message, sPath, session, false, path, relativeReferenceAdjustment)
        else
          SendError(response, HTTP_ERR_INTERNAL, aFormat, lang, e.Message, sPath, session, false, path, relativeReferenceAdjustment);
    end;
  finally
    session.free;
  end;
end;

function TFhirWebServer.HandleWebCreate(request: TFHIRRequest; response: TFHIRResponse) : TDateTime;
var
  profile : TFhirStructureDefinition;
  builder : TQuestionnaireBuilder;
  questionnaire : TFHIRQuestionnaire;
  s, id, fid : String;
begin
   // get the right questionnaire
  if request.Parameters.GetVar('profile').StartsWith('Profile/') then
  begin
    id := request.Parameters.GetVar('profile').Substring(8);
    profile := GetResource(request.Session, frtStructureDefinition, request.Lang, id, '','') as TFHirStructureDefinition;
  end
  else
    profile := FindResource(request.Session, frtStructureDefinition, request.Lang, 'url='+request.Parameters.GetVar('profile'), id) as TFHirStructureDefinition;
  try
    fid := request.baseUrl+'Profile/'+id+'/$questionnaire';
    s := FFhirStore.QuestionnaireCache.getForm(frtStructureDefinition, id);
    if s = '' then
    begin
      builder := TQuestionnaireBuilder.Create;
      try
        questionnaire := FFhirStore.QuestionnaireCache.getQuestionnaire(frtStructureDefinition, id);
        try
          if questionnaire = nil then
          begin
            builder.Profile := profile.Link;
            builder.OnExpand := FFhirStore.ExpandVS;
            builder.onLookupCode := FFhirStore.LookupCode;
            builder.QuestionnaireId := fid;
            builder.onLookupReference := LookupReference;
            builder.Context := request.Link;

            builder.build;
            questionnaire := builder.Questionnaire.Link;
            FFhirStore.QuestionnaireCache.putQuestionnaire(frtStructureDefinition, id, questionnaire, builder.Dependencies);
          end;
          // convert to xhtml
          s := transform1(questionnaire, request.Lang, FAltPath+'QuestionnaireToHTML.xslt', true);
          FFhirStore.QuestionnaireCache.putForm(frtStructureDefinition, id, s, builder.Dependencies);
        finally
          questionnaire.Free;
        end;
      finally
        builder.free;
      end;
    end;

    // insert page headers:
    s := s.Replace('<!--header insertion point-->', TFHIRXhtmlComposer.PageLinks);
    s := s.Replace('<!--body top insertion point-->', TFHIRXhtmlComposer.Header(request.Session, request.baseUrl, request.Lang)+
      '<p><a href="'+builder.QuestionnaireId+'">Questionnaire for this form</a>.'+
      ' The QuestionnaireAnswers should be submitted as a POST to <i>'+request.baseUrl+'$qa-post</i> with a questionnaire reference of <a href="'+builder.QuestionnaireId+'">'+builder.QuestionnaireId+'</a></p>'#13#10);
    s := s.Replace('<!--body bottom insertion point-->', TFHIRXhtmlComposer.Footer(request.baseUrl, request.lang, false));
    s := s.replace('var questionnaireAnswersEndpoint = null;', 'var questionnaireAnswersEndpoint = "'+request.baseUrl+'$qa-post";');
    response.body := s;
    result := Now; //don't want anyone caching anything
    response.ContentType := 'text/html; charset=UTF-8';
  finally
    profile.free;
  end;
end;

function TFhirWebServer.HandleWebEdit(request: TFHIRRequest; response: TFHIRResponse) : TDateTime;
var
  typ, id, ver : String;
  r : TFHIRResource;
  s : String;
  comp : TFHIRComposer;
  i : integer;
begin
  result := 0;

   // get the right questionnaire
  StringSplit(request.Id, '/', typ, s);
  StringSplit(s, '/', id, ver);
  i := StringArrayIndexOfSensitive(CODES_TFhirResourceType, typ);
  if i = -1 then
    raise Exception.Create('Unknown resource type '+typ);

  r := GetResource(request.Session, TFHIRResourceType(i), request.Lang, id, '', '');
  try
    if r is TFhirOperationOutcome then
    begin
      response.Resource := r.Link;
      response.HTTPCode := 500;
      response.Message := 'Internal Error';
    end
    else
    begin

      if request.Parameters.GetVar('srcformat') = 'json' then
        comp := TFHIRJsonComposer.Create(request.Lang)
      else
        comp := TFHIRXMLComposer.Create(request.Lang);
      try
        s := comp.Compose(r, true, nil);
      finally
        comp.Free;
      end;

      s :=
        '<?xml version="1.0" encoding="UTF-8"?>'+#13#10+
        '<!DOCTYPE HTML "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'+#13#10+
        ''+#13#10+
        '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">'+#13#10+
        '<head>'+#13#10+
        '    <title>Direct Edit for /'+typ+'/'+id+'</title>'+#13#10+
        TFHIRXhtmlComposer.PageLinks+
        FHIR_JS+
        '</head>'+#13#10+
        ''+#13#10+
        '<body>'+#13#10+
        ''+#13#10+
        TFHIRXhtmlComposer.Header(request.Session, request.baseUrl, request.Lang)+
        '<h2>Direct Edit for '+request.Id+'</h2>'+#13#10+
        '<form action="'+request.baseUrl+'_web/'+typ+'/'+id+'/$post" method="POST">'#13#10+
        '  <input type="hidden" name="srcformat" value="'+request.Parameters.GetVar('srcformat')+'"/>'#13#10+
        '  <textarea cols="80" rows="24" name="source" style="white-space:pre">'+FormatXMLForTextArea(s)+#13#10'</textarea><br/>'#13#10+
        '  <input type="submit" value="Save"/>'#13#10+
        '</form>'#13#10+
        TFHIRXhtmlComposer.Footer(request.baseUrl, request.lang, true);

      response.body := s;
      result := Now; //don't want anyone caching anything
      response.ContentType := 'text/html; charset=UTF-8';
    end;
  finally
    r.free;
  end;
end;

function TFhirWebServer.HandleWebPost(request: TFHIRRequest; response: TFHIRResponse) : TDateTime;
var
  s, typ, id, ver : String;
  p : TParseMap;
  prsr : TFHIRParser;
  i : integer;
begin
  StringSplit(request.Id, '/', typ, s);
  StringSplit(s, '/', id, ver);
  request.Id := Id;
  i := StringArrayIndexOfSensitive(CODES_TFhirResourceType, typ);
  if i = -1 then
    raise Exception.Create('Unknown resource type '+typ);
  request.ResourceType := TFhirResourceType(i);
  request.CommandType := fcmdUpdate;

  p := TParseMap.create(TEncoding.UTF8.GetString(request.Content.AsBytes), true);
  try
    if p.GetVar('srcformat') = 'json' then
      prsr := TFHIRJsonParser.Create(request.Lang)
    else
      prsr := TFHIRXMLParser.Create(request.Lang);
    try
      s := p.GetVar('source');
      prsr.source := TStringStream.Create(s, TEncoding.UTF8);
      try
        prsr.Parse;
        request.Resource := prsr.resource.Link;
        ProcessRequest(request, response, false);
        if response.HTTPCode < 300 then
        begin
          response.HTTPCode := 303;
          response.Location := request.baseUrl+typ+'/'+id;
        end;
      finally
        prsr.source.Free;
      end;
    finally
      prsr.Free;
    end;
  finally
    p.Free;
  end;
  result := 0;
end;

function TFhirWebServer.HandleWebProfile(request: TFHIRRequest; response: TFHIRResponse) : TDateTime;
var
  id, ver, fullid : String;
  profile : TFHirStructureDefinition;
  builder : TQuestionnaireBuilder;
  questionnaire : TFHIRQuestionnaire;
  s : String;
begin
   // get the right questionnaire
  StringSplit(request.Id.Substring(8), '/', id, ver);
  profile := GetResource(request.Session, frtStructureDefinition, request.Lang, id, ver, '') as TFHirStructureDefinition;
  try
    fullid := request.baseUrl+'Profile/'+id+'/$questionnaire';
    s := FFhirStore.QuestionnaireCache.getForm(frtStructureDefinition, id);
    if s = '' then
    begin
      builder := TQuestionnaireBuilder.Create;
      try
        questionnaire := FFhirStore.QuestionnaireCache.getQuestionnaire(frtStructureDefinition, id);
        try
          if questionnaire = nil then
          begin
            builder.Profile := profile.Link;
            builder.OnExpand := FFhirStore.ExpandVS;
            builder.onLookupCode := FFhirStore.LookupCode;
            builder.onLookupReference := LookupReference;
            builder.Context := request.Link;
            builder.QuestionnaireId := fullid;
            builder.build;
            questionnaire := builder.Questionnaire.Link;
            FFhirStore.QuestionnaireCache.putQuestionnaire(frtStructureDefinition, id, questionnaire, builder.Dependencies);
          end;
          // convert to xhtml
          s := transform1(questionnaire, request.Lang, FAltPath+'QuestionnaireToHTML.xslt', true);
          FFhirStore.QuestionnaireCache.putForm(frtStructureDefinition, id, s, builder.Dependencies);
        finally
          questionnaire.Free;
        end;
      finally
        builder.free;
      end;
    end;
    // insert page headers:
    s := s.Replace('<!--header insertion point-->', TFHIRXhtmlComposer.PageLinks);
    s := s.Replace('<!--body top insertion point-->', TFHIRXhtmlComposer.Header(request.Session, request.baseUrl, request.Lang));
    s := s.Replace('<!--body bottom insertion point-->', TFHIRXhtmlComposer.Footer(request.baseUrl, request.lang, false));
    s := s.replace('var questionnaireAnswersEndpoint = null;', 'var questionnaireAnswersEndpoint = "'+request.baseUrl+'$qa-post";');
    response.body := s;
    result := Now; //don't want anyone caching anything
    response.ContentType := 'text/html; charset=UTF-8';
  finally
    profile.free;
  end;
end;

function TFhirWebServer.HandleWebPatient(request: TFHIRRequest; response: TFHIRResponse; secure : boolean) : TDateTime;
var
  id, ver : String;
  s, xhtml : String;
  patient : TFHIRPatient;
begin
  result := 0;
  StringSplit(request.Id.Substring(8), '/', id, ver);
  patient := GetResource(request.Session, frtPatient, request.Lang, id, ver, '') as TFHIRPatient;
  try
    xhtml := FhirHtmlToText(patient.text.div_);
  finally
    patient.Free;
  end;

  s := FileToString(FAltPath+'patient.html', TEncoding.UTF8);
  s := s.Replace('[%id%]', FName, [rfReplaceAll]);
  s := s.Replace('[%ver%]', FHIR_GENERATED_VERSION+'-'+FHIR_GENERATED_REVISION, [rfReplaceAll]);
  s := s.Replace('[%web%]', WebDesc, [rfReplaceAll]);
  s := s.Replace('[%patient-details%]', xhtml, [rfReplaceAll]);
  s := s.Replace('[%patient-id%]', id, [rfReplaceAll]);
  s := s.Replace('[%admin%]', FAdminEmail, [rfReplaceAll]);
  if FPort = 80 then
    s := s.Replace('[%host%]', FHost, [rfReplaceAll])
  else
    s := s.Replace('[%host%]', FHost+':'+inttostr(FPort), [rfReplaceAll]);
  if FSSLPort = 443 then
    s := s.Replace('[%securehost%]', FHost, [rfReplaceAll])
  else
    s := s.Replace('[%securehost%]', FHost+':'+inttostr(FSSLPort), [rfReplaceAll]);
  if FPort = 80 then
    s := s.Replace('[%baseOpen%]', FHost+FBasePath, [rfReplaceAll])
  else
    s := s.Replace('[%baseOpen%]', FHost+':'+inttostr(FPort)+FBasePath, [rfReplaceAll]);
  if FSSLPort = 443 then
    s := s.Replace('[%baseSecure%]', FHost+FSecurePath, [rfReplaceAll])
  else
    s := s.Replace('[%baseSecure%]', FHost+':'+inttostr(FSSLPort)+FSecurePath, [rfReplaceAll]);
  s := s.Replace('[%endpoints%]', EndPointDesc(secure), [rfReplaceAll]);

  response.Body := s;
  response.ContentType := 'text/html; charset=UTF-8';
end;

function TFhirWebServer.HandleWebQuestionnaire(request: TFHIRRequest; response: TFHIRResponse) : TDateTime;
var
  id, ver : String;
  questionnaire : TFHIRQuestionnaire;
  s : String;
begin
   // get the right questionnaire
  StringSplit(request.Id.Substring(14), '/', id, ver);
  questionnaire := GetResource(request.Session, frtQuestionnaire, request.Lang, id, ver, '') as TFHirQuestionnaire;
  try
    // convert to xhtml
    s := transform1(questionnaire, request.Lang, FAltPath+'QuestionnaireToHTML.xslt', false);
    // insert page headers:
    s := s.Replace('<!--header insertion point-->', TFHIRXhtmlComposer.PageLinks);
    s := s.Replace('<!--body top insertion point-->', TFHIRXhtmlComposer.Header(request.Session, request.baseUrl, request.Lang));
    s := s.Replace('<!--body bottom insertion point-->', TFHIRXhtmlComposer.Footer(request.baseUrl, request.lang, false));
    s := s.replace('var questionnaireAnswersEndpoint = null;', 'var questionnaireAnswersEndpoint = "'+request.baseUrl+'/QuestionnaireAnswers";');
    response.body := s;
    result := Now; //don't want anyone caching anything
    response.ContentType := 'text/html; charset=UTF-8';
  finally
    questionnaire.free;
  end;
end;

function TFhirWebServer.HandleWebQuestionnaireInstance(request: TFHIRRequest; response: TFHIRResponse) : TDateTime;
var
  typ, id, ver : String;
  r : TFHIRResource;
  qa : TFhirQuestionnaireAnswers;
  q : TFhirQuestionnaire;
  s, j : String;
  json : TFHIRJsonComposer;
  i : integer;
begin
  result := 0;

   // get the right questionnaire
  StringSplit(request.Id, '/', typ, s);
  StringSplit(s, '/', id, ver);
  i := StringArrayIndexOfSensitive(CODES_TFhirResourceType, typ);
  if i = -1 then
    raise Exception.Create('Unknown resource type '+typ);

  r := GetResource(request.Session, TFHIRResourceType(i), request.Lang, id, ver, 'qa-edit');
  try
    if r is TFhirOperationOutcome then
    begin
      response.Resource := r.Link;
      response.HTTPCode := 500;
      response.Message := 'Internal Error';
    end
    else
    begin
      qa := r as TFhirQuestionnaireAnswers;
      q := (FindContainedResource(qa, qa.questionnaire) as TFhirQuestionnaire).link;
      if q = nil then
        raise Exception.Create('Unable to fetch Questionnaire "'+qa.questionnaire.reference.Substring(1)+'"');

      // convert to xhtml
      s := transform1(q, request.Lang, FAltPath+'QuestionnaireToHTML.xslt', true);

      // make clean qa
      qa.questionnaire.reference := 'Questionnaire/'+qa.questionnaire.reference.Substring(1);
      qa.containedList.Clear;
      json := TFHIRJsonComposer.Create(request.Lang);
      try
        j := json.Compose(qa, false, nil);
      finally
        json.Free;
      end;

      // insert page headers:
      s := s.Replace('<!--header insertion point-->', TFHIRXhtmlComposer.PageLinks);
      s := s.Replace('<!--body top insertion point-->', TFHIRXhtmlComposer.Header(request.Session, request.baseUrl, request.Lang));
      s := s.Replace('<!--body bottom insertion point-->', TFHIRXhtmlComposer.Footer(request.baseUrl, request.lang, false));
      // insert the answer:
      s := s.Replace('var questionnaireAnswers=null;', 'var questionnaireAnswers='+j+';');
      response.body := s;
      result := Now; //don't want anyone caching anything
      response.ContentType := 'text/html; charset=UTF-8';
    end;
  finally
    r.free;
  end;
end;

function TFhirWebServer.HandleWebUIRequest(request: TFHIRRequest; response: TFHIRResponse; secure : boolean) : TDateTime;
begin
  if request.Id.EndsWith('$qa-edit') then
    result := HandleWebQuestionnaireInstance(request, response)
  else if request.Id.EndsWith('$edit') then
    result := HandleWebEdit(request, response)
  else if request.Id.EndsWith('$post') then
    result := HandleWebPost(request, response)
  else if request.Id.StartsWith('Questionnaire/') then
    result := HandleWebQuestionnaire(request, response)
  else if request.Id.StartsWith('Profile/') then
    result := HandleWebProfile(request, response)
  else if request.Id.StartsWith('Patient/') then
    result := HandleWebPatient(request, response, secure)
  else if request.Id ='Create' then
    result := HandleWebCreate(request, response)
  else
    raise Exception.Create('Unknown request: '+request.Id);
end;


procedure TFhirWebServer.SendError(response: TIdHTTPResponseInfo; status : word; format : TFHIRFormat; lang, message, url : String; session : TFhirSession; addLogins : boolean; path : String; relativeReferenceAdjustment : integer; code : String = '');
var
  issue : TFhirOperationOutcome;
  report :  TFhirOperationOutcomeIssue;
  oComp : TFHIRComposer;
  e : TFhirExtension;
begin
  response.ResponseNo := status;
  response.FreeContentStream := true;

  if format = ffAsIs then
  begin
    response.ContentType := 'text/plain';
    response.ContentStream := StringToUTF8Stream(message);
  end
  else
  begin
    issue := TFhirOperationOutcome.create;
    try
      issue.text := TFhirNarrative.create;
      issue.text.status := NarrativeStatusGenerated;
      issue.text.div_ := ParseXhtml(lang, '<div><p>'+FormatTextToXML(message)+'</p></div>', xppReject);
      if addLogins then
      begin
        if FAuthServer.HL7Appid <> '' then
        begin
          e := issue.ExtensionList.Append;
          e.url := 'http://www.healthintersections.com.au/fhir/extensions#auth-token';
          e.value := TFhirString.create('http://hl7.amg-hq.net/tools/signup_redirect.cfm?apiKey='+FAuthServer.HL7Appid+'&returnURL='+EncodeMime(path)+'/state/'+FAuthServer.MakeLoginToken(path, apHL7));
        end;
        if FAuthServer.FacebookAppid <> '' then
        begin
          e := issue.ExtensionList.Append;
          e.url := 'http://www.healthintersections.com.au/fhir/extensions#auth-token';
          e.value := TFhirString.create('https://www.facebook.com/dialog/oauth?client_id='+FAuthServer.FacebookAppid+'&redirect_uri='+path+'&state='+FAuthServer.MakeLoginToken(path, apFacebook));
        end;
        if FAuthServer.GoogleAppid <> '' then
        begin
          e := issue.ExtensionList.Append;
          e.url := 'http://www.healthintersections.com.au/fhir/extensions#auth-token';
          e.value := TFhirString.create('https://accounts.google.com/o/oauth2/auth?client_id='+FAuthServer.GoogleAppid+'&response_type=code&scope=openid%20email&redirect_uri='+path+'&state='+FAuthServer.MakeLoginToken(path, apGoogle));
        end;
      end;
      report := issue.issueList.Append;
      report.severity := IssueSeverityError;
      report.details := message;
      if (code <> '') then
      begin
        report.code := TFhirCodeableConcept.Create;
        with report.code.codingList.Append do
        begin
          system := 'http://hl7.org/fhir/issue-type';
          code := code;
        end;
      end;
      response.ContentStream := TMemoryStream.Create;
      oComp := nil;
      case format of
        ffXml: oComp := TFHIRXmlComposer.Create(lang);
        ffXhtml:
          begin
          oComp := TFHIRXhtmlComposer.Create(lang);
          TFHIRXhtmlComposer(oComp).BaseURL := AppendForwardSlash(url);
          TFHIRXhtmlComposer(oComp).Session := Session.Link;
          TFHIRXhtmlComposer(oComp).relativeReferenceAdjustment := relativeReferenceAdjustment;
          end;
        ffJson: oComp := TFHIRJsonComposer.Create(lang);
      end;
      try
        response.ContentType := oComp.MimeType;
        oComp.Compose(response.ContentStream, issue, false, nil);
        response.ContentStream.Position := 0;
      finally
        oComp.free;
      end;
    finally
      issue.free;
    end;
  end;
  response.WriteContent;
end;

function extractProp(contentType, name : String) : string;
begin
  if contentType.Contains(name+'=') then
  begin
    result := contentType.Substring(contentType.IndexOf(name+'=')+name.Length+1);
    if result.Contains(';') then
      result := result.Substring(0, result.indexOf(';'));
  end
  else
    result := '';
end;

Const
  META_CMD_NAME = '$meta';

Function TFhirWebServer.BuildRequest(lang, sBaseUrl, sHost, sOrigin, sClient, sContentLocation, sCommand, sResource, sContentType, sContentAccept, sContentEncoding, sCookie, provenance : String; oPostStream : TStream; oResponse : TFHIRResponse; var aFormat : TFHIRFormat;
   var redirect : boolean; form : TIdSoapMimeMessage; bAuth, secure : Boolean; out relativeReferenceAdjustment : integer; var pretty : boolean) : TFHIRRequest;
Var
  sURL, sId, sType, msg : String;
  aResourceType : TFHIRResourceType;
  oRequest : TFHIRRequest;
  parser : TFHIRParser;

  Function NextSegment(var url : String):String;
  var
    i : integer;
  Begin
    i := StringFind(url, ['/']);
    if i = 0 then
    begin
      result := url;
      url := '';
    end
    else
    begin
      inc(relativeReferenceAdjustment);
      result := copy(url, 1, i-1);
      url := copy(url, i + 1, $FFF);
    end;
  End;
  procedure ForceMethod(sMethod : String);
  begin
    if (sCommand <> sMethod) Then
      raise ERestfulException.Create('TFhirWebServer', 'HTTPRequest', StringFormat(GetFhirMessage('MSG_BAD_FORMAT', lang), [sResource, sMethod]), HTTP_ERR_FORBIDDEN);
  end;
var
  i : integer;
  session : TFhirSession;
  check : boolean;
  s : String;
  comp : TIdCompressorZLib;
  mem : TMemoryStream;
  cursor : integer;
Begin
  relativeReferenceAdjustment := 0;
  Result := nil;
  oRequest := TFHIRRequest.Create;
  try
    oRequest.Lang := lang;
    oResponse.origin := sOrigin;
    oRequest.PostFormat := ffAsIs;
    oResponse.Format := ffAsIs;
    aFormat := ffAsIs;
    oRequest.baseUrl := sHost + AppendForwardSlash(sBaseURL);
    oRequest.url := sHost + sResource;
    oRequest.lastModifiedDate := 0; // Xml
    oRequest.contentLocation := sContentLocation; // for version aware updates
    oRequest.form := form;
    oRequest.Provenance := processProvenanceHeader(provenance, lang);

    If Not StringStartsWithSensitive(sResource, sBaseURL) Then
    begin
      if StringStartsWith(sResource, '/images/', false) then
        Raise ERestfulException.Create('TFhirWebServer', 'HTTPRequest', 'images not served', HTTP_ERR_NOTFOUND)
      else
        Raise ERestfulException.Create('TFhirWebServer', 'HTTPRequest', StringFormat(GetFhirMessage('MSG_NO_MODULE', lang), [sResource]), HTTP_ERR_NOTFOUND);
    end;

    sURL := Copy(sResource, length(sBaseURL)+1, $FFF);
    i := StringFind(sURL, ['?']);
    if (i = 0) then
      oRequest.LoadParams('')
    else
    begin
      oRequest.LoadParams(copy(sURL, i+1, $FFF));
      sUrl := copy(sURL, 1, i-1);
    end;
    if sUrl.StartsWith('/') then
      sUrl := sUrl.Substring(1);
    if form <> nil then
      oRequest.LoadParams(form);

    if (sCommand <> 'GET') then
    begin
      if oRequest.Parameters.VarExists('_format') and (form = nil) and (oRequest.Parameters.GetVar('_format') <> '') then
        sContentType := oRequest.Parameters.GetVar('_format');
      if StringStartsWithInsensitive(sContentType, 'application/json') or StringStartsWithInsensitive(sContentType, 'application/fhir+json') or StringStartsWithInsensitive(sContentType, 'application/json+fhir') or StringStartsWithInsensitive(sContentType, 'json') or StringStartsWithInsensitive(sContentType, 'text/json') Then
        oRequest.PostFormat := ffJson
      else if StringStartsWithInsensitive(sContentType, 'text/html') or StringStartsWithInsensitive(sContentType, 'html') or StringStartsWithInsensitive(sContentType, 'application/x-zip-compressed') or StringStartsWithInsensitive(sContentType, 'application/zip') Then
        oRequest.PostFormat := ffXhtml
      else if StringStartsWithInsensitive(sContentType, 'text/xml') or StringStartsWithInsensitive(sContentType, 'application/xml') or
          StringStartsWithInsensitive(sContentType, 'application/fhir+xml') or StringStartsWithInsensitive(sContentType, 'application/xml+fhir') or StringStartsWithInsensitive(sContentType, 'xml') Then
        oRequest.PostFormat := ffXML;
    end;

    if oRequest.Parameters.VarExists('_format') and (oRequest.Parameters.GetVar('_format') <> '') then
      sContentAccept := oRequest.Parameters.GetVar('_format');
    if StringExistsSensitive(sContentAccept, 'application/json') or StringExistsInsensitive(sContentAccept, 'json') Then
      oResponse.Format := ffJson
    else if StringExistsSensitive(sContentAccept, 'text/xml') Then
      oResponse.Format := ffXML
    else if StringExistsSensitive(sContentAccept, 'text/html') Then
      oResponse.Format := ffXhtml
    else if StringExistsSensitive(sContentAccept, 'application/xml') Then
      oResponse.Format := ffXML
    else if StringExistsInsensitive(sContentAccept, 'xml') Then
      oResponse.Format := ffXML
    else if StringExistsInsensitive(sContentAccept, 'html') Then
      oResponse.Format := ffXhtml
    else if oRequest.PostFormat <> ffAsIs then
      oResponse.Format := oRequest.PostFormat;

    if oRequest.Parameters.VarExists('_pretty') then
      pretty := oRequest.Parameters.GetVar('_pretty') = 'true'
    else if sContentAccept.Contains('pretty=') then
      pretty := extractProp(sContentAccept, 'pretty') = 'true'
    else
      pretty := false;

    aFormat := oResponse.Format;

    // ok, now that we've read the content types, security check
    if bAuth and not (sURL = 'metadata') then
    begin
      if sUrl = 'logout' then
      begin
        FFhirStore.EndSession(sCookie, sClient);
        oRequest.session := nil;
        redirect := true;
      end
      else if (sURL = 'internal') then
        redirect := true
      else if (sUrl <> 'auth-login') and FFhirStore.GetSession(sCookie, session, check) then
      begin
        if check and not CheckSessionOK(session, sClient) then
          Raise ERestfulAuthenticationNeeded.Create('TFhirWebServer', 'HTTPRequest', GetFhirMessage('MSG_AUTH_REQUIRED', lang), msg, HTTP_ERR_UNAUTHORIZED);
        oRequest.session := session
      end
      else
        Raise ERestfulAuthenticationNeeded.Create('TFhirWebServer', 'HTTPRequest', GetFhirMessage('MSG_AUTH_REQUIRED', lang), msg, HTTP_ERR_UNAUTHORIZED);
    end
    else
      oRequest.session := FFhirStore.CreateImplicitSession(sClient, false);

    relativeReferenceAdjustment := 0;
    if not redirect then
    begin
      sType := NextSegment(sURL);
      if (sType = '') Then
      begin
        if sCommand = 'OPTIONS' then
          oRequest.CommandType := fcmdConformanceStmt
        else if (sCommand = 'POST') then
        begin
          if form <> nil then
          begin
            s := oRequest.Parameters.GetVar('op');
            if (s = 'transaction') or (s = '') then
              oRequest.CommandType := fcmdTransaction
            else if (s = 'validation') or (s = 'validate') then
              oRequest.CommandType := fcmdValidate
            else if (s = 'mailBox') then
              oRequest.CommandType := fcmdMailBox
            else
              raise Exception.create('Unknown Operation: '+s);
          end
          else
            oRequest.CommandType := fcmdTransaction
        end
        else
        begin
          ForceMethod('GET');
          if oRequest.Parameters.Count > 0 then
            oRequest.CommandType := fcmdSearch
          else
            oRequest.CommandType := fcmdUnknown;
        end
      end
      else if (sCommand = 'OPTIONS') then
        oRequest.CommandType := fcmdNull
      else if (sType = '_web') then // special
      begin
        if sCommand <> 'POST' then
          ForceMethod('GET');
        oRequest.CommandType := fcmdWebUI;
        oRequest.id := sUrl;
        sUrl := '';
      end
      else if StringStartsWith(sType, '$', false)  then
      begin
        oRequest.CommandType := fcmdOperation;
        oRequest.OperationName := sType.Substring(1);
        if sCommand <> 'GET' then
          ForceMethod('POST');
      end
      else if (sType = META_CMD_NAME) then
      begin
        ForceMethod('GET');
        oRequest.CommandType := fcmdGetMeta;
      end
      else if (sType = '_history') then
      begin
        ForceMethod('GET');
        oRequest.CommandType := fcmdHistorySystem;
      end
      else if (sType = 'metadata') or (sType = 'metadata.xml') or (sType = 'metadata.htm') or (sType = 'metadata.json') Then
      begin
        oRequest.CommandType := fcmdConformanceStmt;
        ForceMethod('GET');
        if sType = 'metadata.htm' then
          oResponse.format := ffXhtml
        else if sType = 'metadata.xml' then
          oResponse.format := ffXml
        else if sType = 'metadata.json' then
          oResponse.format := ffJson
      end
      else if (sType = 'Mailbox') then
      begin
        oRequest.CommandType := fcmdMailbox;
        ForceMethod('POST');
      end
      else if (sType = 'validation') then
      begin
        oRequest.CommandType := fcmdValidate;
        ForceMethod('POST');
        if oRequest.Parameters.VarExists('profile') and (oRequest.Parameters.GetVar('profile') <> '') then
          oRequest.categories.AddValue(TAG_FHIR_SCHEME_PROFILE, 'http://localhost/'+oRequest.Parameters.GetVar('profile'), '');
      end
      else if (sType = '_search') then
      begin
        oRequest.CommandType := fcmdSearch;
        if (sCommand <> 'GET') and (sCommand <> 'POST') then
          raise ERestfulException.Create('TFhirWebServer', 'HTTPRequest', StringFormat(GetFhirMessage('MSG_BAD_SYNTAX', lang), [sResource]), HTTP_ERR_BAD_REQUEST);
      end
      else
      begin
        if (sType <> '') And not RecogniseFHIRResourceManagerName(sType, aResourceType) Then
          Raise ERestfulException.Create('TFhirWebServer', 'HTTPRequest', StringFormat(GetFhirMessage('MSG_NO_MODULE', lang), [sType]), HTTP_ERR_NOTFOUND);
        oRequest.ResourceType := aResourceType;
        sId := NextSegment(sURL);
        if sId = '' then
        begin
          if sCommand = 'GET' then
          begin
            oRequest.CommandType := fcmdSearch;
            oRequest.DefaultSearch := true;
          end
          else if sCommand = 'POST' then
            oRequest.CommandType := fcmdCreate
          else if (scommand = 'PUT') then
          begin
            oRequest.CommandType := fcmdUpdate;
            oRequest.DefaultSearch := true;
          end
          else if (scommand = 'DELETE') then
          begin
            oRequest.CommandType := fcmdDelete;
            oRequest.DefaultSearch := true;
          end
          else
            raise ERestfulException.Create('TFhirWebServer', 'HTTPRequest', StringFormat(GetFhirMessage('MSG_BAD_SYNTAX', lang), [sResource]), HTTP_ERR_BAD_REQUEST);
        end
        else if StringStartsWith(sId, '$', false) then
        begin
          oRequest.CommandType := fcmdOperation;
          oRequest.OperationName := sId.Substring(1);
          if sCommand <> 'GET' then
            ForceMethod('POST');
        end
        else if not StringStartsWith(sId, '_', true) Then
        begin
          // operations on a resource
          CheckId(lang, sId);
          oRequest.Id := sId;
          sId := NextSegment(sUrl);
          if (sId = '') Then
          begin
            if sCommand = 'GET' Then
              oRequest.CommandType := fcmdRead
            else if sCommand = 'PUT' Then
              oRequest.CommandType := fcmdUpdate
            else if sCommand = 'DELETE' Then
              oRequest.CommandType := fcmdDelete
            else if sCommand = 'OPTIONS' then // CORS
              oRequest.CommandType := fcmdConformanceStmt
            else
              raise ERestfulException.Create('TFhirWebServer', 'HTTPRequest', StringFormat(GetFhirMessage('MSG_BAD_FORMAT', lang), [sResource, 'GET, PUT or DELETE']), HTTP_ERR_FORBIDDEN);
          end
          else if StringStartsWith(sId, '$', false)  then
          begin
            oRequest.CommandType := fcmdOperation;
            oRequest.OperationName := sId.Substring(1);
            if sCommand <> 'GET' then
              ForceMethod('POST');
          end
          else if (sId = '_history') then
          begin
            sId := NextSegment(sURL);
            if sId = '' then
            begin
              ForceMethod('GET');
              oRequest.CommandType := fcmdHistoryInstance;
            end
            else if not StringStartsWith(sId, '_', true) Then
            begin
              CheckId(lang, sId);
              oRequest.SubId := sId;
              sId := NextSegment(sURL);
              if sid = '' then
              begin
                ForceMethod('GET');
                oRequest.CommandType := fcmdVersionRead;
              end
              else if (sid = META_CMD_NAME) then
              begin
                sId := NextSegment(sURL);
                if sId = '' then
                begin
                  if sCommand = 'GET' Then
                    oRequest.CommandType := fcmdGetMeta
                  else if sCommand = 'POST' Then
                    oRequest.CommandType := fcmdUpdateMeta
//                  else if sCommand = 'DELETE' Then
//                    oRequest.CommandType := fcmdDeleteTags
                  else
                    raise ERestfulException.Create('TFhirWebServer', 'HTTPRequest', StringFormat(GetFhirMessage('MSG_BAD_FORMAT', lang), [sResource, 'GET, POST or DELETE']), HTTP_ERR_FORBIDDEN);
                end else if sId = '_delete' then
                begin
                  ForceMethod('POST');
                  oRequest.CommandType := fcmdDeleteMeta;
                end
                else
                  raise ERestfulException.Create('TFhirWebServer', 'HTTPRequest', StringFormat(GetFhirMessage('MSG_BAD_FORMAT', lang), [sResource, 'GET, POST or DELETE']), HTTP_ERR_FORBIDDEN);
              end
              else
                raise ERestfulException.Create('TFhirWebServer', 'HTTPRequest', StringFormat(GetFhirMessage('MSG_BAD_SYNTAX', lang), [sResource]), HTTP_ERR_BAD_REQUEST);
            end
            else
              raise ERestfulException.Create('TFhirWebServer', 'HTTPRequest', StringFormat(GetFhirMessage('MSG_BAD_SYNTAX', lang), [sResource]), HTTP_ERR_BAD_REQUEST);
          end
          else if (sId = META_CMD_NAME) then
          begin
            if sCommand = 'GET' Then
              oRequest.CommandType := fcmdGetMeta
            else if sCommand = 'POST' Then
            begin
              if (sUrl = '_delete') then
              begin
                sUrl := '';
                oRequest.CommandType := fcmdDeleteMeta;
              end
              else
                oRequest.CommandType := fcmdUpdateMeta
            end
            else
              raise ERestfulException.Create('TFhirWebServer', 'HTTPRequest', StringFormat(GetFhirMessage('MSG_BAD_FORMAT', lang), [sResource, 'GET, or POST']), HTTP_ERR_FORBIDDEN);
          end
          else if sId = '*' then // all tpes
          begin
            if oRequest.ResourceType <> frtPatient then
              raise ERestfulException.Create('TFhirWebServer', 'HTTPRequest', StringFormat(GetFhirMessage('MSG_UNKNOWN_COMPARTMENT', lang), [sResource, 'GET, POST or DELETE']), HTTP_ERR_FORBIDDEN);

            oRequest.CompartmentId := oRequest.Id;
            oRequest.CommandType := fcmdSearch;
            oRequest.ResourceType := frtNull;
            oRequest.Id := '';
          end
          else if StringArrayExistsInSensitive(CODES_TFhirResourceType, sId) then
          begin
            aResourceType := TFHIRResourceType(StringArrayIndexOfInSensitive(CODES_TFhirResourceType, sId));
            if (COMPARTMENT_PARAM_NAMES[oRequest.ResourceType, aResourceType] <> '') then
            begin
              if oRequest.ResourceType <> frtPatient then
                raise ERestfulException.Create('TFhirWebServer', 'HTTPRequest', StringFormat(GetFhirMessage('MSG_UNKNOWN_COMPARTMENT', lang), [sResource, 'GET, POST or DELETE']), HTTP_ERR_FORBIDDEN);

              oRequest.CompartmentId := oRequest.Id;
              oRequest.CommandType := fcmdSearch;
              oRequest.ResourceType := aResourceType;
              oRequest.Id := '';
            end
            else
              raise ERestfulException.Create('TFhirWebServer', 'HTTPRequest', StringFormat(GetFhirMessage('MSG_BAD_SYNTAX', lang), [sResource]), HTTP_ERR_BAD_REQUEST);
          end
          else
            raise ERestfulException.Create('TFhirWebServer', 'HTTPRequest', StringFormat(GetFhirMessage('MSG_BAD_SYNTAX', lang), [sResource]), HTTP_ERR_BAD_REQUEST);
        end
        else if (sId = '_validate') Then
        begin
          ForceMethod('POST');
          oRequest.CommandType := fcmdValidate;
          sId := NextSegment(sUrl);
          if sId <> '' Then
          Begin
            if (sURL <> '') or (sId = '') Then
              raise ERestfulException.Create('TFhirWebServer', 'HTTPRequest', 'Bad Syntax in "'+sResource+'"', HTTP_ERR_BAD_REQUEST);
            CheckId(lang, copy(sId, 2, $FF));
            oRequest.Id := copy(sId, 2, $FF);
          End;
        end
        else if (sId = META_CMD_NAME) or (sId = META_CMD_NAME+'.xml') or (sId = META_CMD_NAME+'.json') Then
        begin
          if (sUrl = '_delete') then
          begin
            ForceMethod('POST');
            sUrl := '';
            oRequest.CommandType := fcmdDeleteMeta;
          end
          else if sCommand = 'POST' then
            oRequest.CommandType := fcmdUpdateMeta
          else
          begin
            ForceMethod('GET');
            oRequest.CommandType := fcmdGetMeta;
          end;
        end
        else if (sId = '_search') or (sId = '_search.xml') or (sId = '_search.json') Then
          oRequest.CommandType := fcmdSearch
        else if (sId = '_history') or (sId = '_history.xml') or (sId = '_history.json') Then
        begin
          ForceMethod('GET');
          oRequest.CommandType := fcmdHistoryType
        end
        // Extension on this server - remove?
        else if (sId = '_upload') or (sId = '_upload.htm') then
        begin
          oRequest.CommandType := fcmdUpload;
          oRequest.PostFormat := ffXhtml;
        end
        else
          raise ERestfulException.Create('TFhirWebServer', 'HTTPRequest', StringFormat(GetFhirMessage('MSG_BAD_SYNTAX', lang), ['URL'+sResource]), HTTP_ERR_BAD_REQUEST);
      End;

      if (oRequest.CommandType <> fcmdNull)  then
      begin
        if (sURL <> '') then
          raise ERestfulException.Create('TFhirWebServer', 'HTTPRequest', StringFormat(GetFhirMessage('MSG_BAD_SYNTAX', lang), [sResource]), HTTP_ERR_BAD_REQUEST);

        if (oRequest.Session <> nil) and (oRequest.Session.User <> nil) and (oRequest.Session.PatientList.Count > 0) then
          oRequest.compartments := BuildCompartmentList(oRequest.Session);

        if (oRequest.CommandType in [fcmdTransaction, fcmdUpdate, fcmdValidate, fcmdCreate, fcmdMailbox]) or ((oRequest.CommandType in [fcmdUpload, fcmdSearch, fcmdWebUI, fcmdOperation]) and (sCommand = 'POST') and (oPostStream <> nil) and (oPostStream.Size > 0))
          or ((oRequest.CommandType in [fcmdDelete]) and ((sCommand = 'DELETE')) and (oPostStream <> nil) and (sContentType <> '')) Then
        begin
          oRequest.CopyPost(oPostStream);
          if (sContentType = 'application/x-zip-compressed') or (sContentType = 'application/zip') then
            oRequest.Feed := ProcessZip(lang, oPostStream, NewGuidURN, 'http://hl7.org/fhir', false, nil, cursor)
          else
          begin
            oRequest.Source := TAdvBuffer.Create;
            if sContentEncoding = 'gzip' then
            begin
              mem := TMemoryStream.Create;
              comp := TIdCompressorZLib.Create(nil);
              try
                comp.DecompressStream(oPostStream, mem, 0);
                mem.Position := 0;
                oRequest.source.LoadFromStream(mem);
              finally
                comp.free;
                mem.free;
              end;
            end
            else
              oRequest.Source.LoadFromStream(oPostStream);

            oPostStream.Position := 0;
            if oRequest.ResourceType = frtBinary then
            begin
              oRequest.Resource := TFhirBinary.create;
//!              TFhirBinary(oRequest.Resource).Content.loadFromStream(oPostStream);
//!              TFhirBinary(oRequest.Resource).ContentType := sContentType;
            end
            else if oRequest.CommandType <> fcmdWebUI then
              try
                parser := MakeParser(lang, oRequest.PostFormat, oPostStream, xppReject);
                try
                  oRequest.Resource := parser.resource.Link;
                  if (oRequest.CommandType = fcmdTransaction) and (oRequest.feed = nil) then
                  begin
                    oRequest.feed := TFHIRAtomFeed.create(BundleTypeTransactionResponse);
                    oRequest.Feed.base := oRequest.baseUrl;
                    oRequest.feed.entryList.add(TFHIRAtomEntry.create);
                    oRequest.feed.entryList[0].resource := oRequest.Resource.link;
                    oRequest.feed.entryList[0].resource.id := FhirGUIDToString(CreateGUID);
                    oRequest.resource := nil;
                  end;
                finally
                  parser.free;
                end;
              except
                on e : Exception do
                  if oRequest.CommandType = fcmdValidate then
                    oResponse.Message := e.Message
                  else
                    raise;
              end;
          end;
        end
        else if (oRequest.CommandType in [fcmdUpdateMeta, fcmdDeleteMeta]) then
        begin
          parser := MakeParser(lang, oRequest.PostFormat, oPostStream, xppDrop);
          try
            oRequest.Resource := parser.resource.Link;
          finally
            parser.free;
          end;
        end;
      end;
    end;

    result := oRequest.Link;
  Finally
    oRequest.Free;
  End;
End;

Function TFhirWebServer.ProcessZip(lang : String; oStream : TStream; name, base : String; init : boolean; ini : TIniFile; var cursor : integer) : TFHIRAtomFeed;
var
  rdr : TAdvZipReader;
  p : TFHIRParser;
  i, k : integer;
  s : TAdvVCLStream;
  e : TFHIRAtomEntry;
  f : TFileStream;
  bnd : TFHIRBundle;
  inc : TStringList;
  istart, iend : integer;
  function ok(res : TFHIRResource) : boolean;
  begin
    result := (inc.Count = 0) or (inc.IndexOf(CODES_TFHIRResourceType[res.ResourceType]) > -1);
  end;
begin
  inc := TStringList.Create;
  result := TFHIRAtomFeed.Create(BundleTypeTransaction);
  try
    if init and (ini <> nil) then
      inc.CommaText := ini.ReadString('control', 'include', '');
    result.id := NewGuidURN;
    result.base := base;
    rdr := carry.link as TAdvZipReader;
    try
      if (rdr = nil) or (name <> carryName) then
      begin
        rdr.Free;
        carry.free;
        rdr := TAdvZipReader.Create;
        s := TAdvVCLStream.Create;
        s.Stream := oStream;
        rdr.Stream := s;
        rdr.Parts := TAdvZipPartList.Create;
        rdr.ReadZip;
        carry := rdr.Link as TAdvZipReader;
        carryName := name;
      end;

      if (init) then
      begin
        iStart := 0;
        iEnd := rdr.Parts.Count - 1;
      end
      else
      begin
        iStart := ini.ReadInteger('process', 'start', 0);
        iEnd := iStart + 1000;
        if iEnd > rdr.Parts.Count - 1 then
          iEnd := rdr.Parts.Count - 1;
      end;

      for i := iStart to iEnd Do
      begin
        if rdr.Parts[i].name.EndsWith('.json') then
          p := TFHIRJsonParser.create(lang)
        else
          p := TFHIRXmlParser.create(lang);
        try
          p.source := TBytesStream.create(rdr.parts[i].AsBytes);
          p.Parse;
          if  p.resource is TFhirBundle then
          begin
            bnd := TFhirBundle(p.resource);
            case bnd.type_ of
              BundleTypeDocument, BundleTypeMessage, BundleTypeHistory, BundleTypeSearchset, BundleTypeCollection :
                 for k := 0 to bnd.entryList.Count - 1 do
                   if ok(bnd.entryList[k].resource) then
                     result.entryList.Add(bnd.entryList[k].link);
              BundleTypeTransaction, BundleTypeTransactionResponse : ; // we ignore these for now
            end;
          end
          else if not (p.resource is TFhirParameters) and ok(p.resource) then
          begin
            e := TFHIRAtomEntry.create;
            try
              e.resource := p.resource.Link;
              result.entryList.add(e.Link);
            finally
              e.free;
            end;
          end;
        finally
          p.source.free;
          p.free;
        end;
      end;
      if iEnd < rdr.Parts.Count - 1 then
        cursor := iEnd + 1
      else
        cursor := -1;
    finally
      rdr.free;
    end;
    result.Link;
  finally
    result.Free;
    inc.Free;
  end;
end;


procedure TFhirWebServer.SSLPassword(var Password: String);
begin
  Password := FSSLPassword;
end;

Procedure TFhirWebServer.ProcessOutput(oRequest : TFHIRRequest; oResponse : TFHIRResponse; response: TIdHTTPResponseInfo; relativeReferenceAdjustment : integer; pretty, gzip : boolean);
var
  oComp : TFHIRComposer;
  b : TBytes;
  stream : TMemoryStream;
  ownsStream : boolean;
  comp : TIdCompressorZLib;
begin
  response.ResponseNo := oResponse.HTTPCode;
  response.ContentType := oResponse.ContentType;
  stream := TMemoryStream.create;
  try
    ownsStream := true;
    if oResponse.Resource <> nil then
    Begin
      if oResponse.Resource is TFhirBinary then
      begin
        if Length(TFhirBinary(oResponse.Resource).content) > 0 then
          stream.Write(TFhirBinary(oResponse.Resource).content[0], Length(TFhirBinary(oResponse.Resource).content));
        stream.Position := 0;
        response.ContentType := TFhirBinary(oResponse.Resource).ContentType;
        if StrToBoolDef(orequest.Parameters.GetVar('no-attachment'), false) then
          response.ContentDisposition := 'attachment;';
        response.Expires := Now + 0.25;
      end
      else
      begin
//        response.Expires := Now; //don't want anyone caching anything
        response.Pragma := 'no-cache';
        if oResponse.Format = ffJson then
          oComp := TFHIRJsonComposer.Create(oRequest.lang)
        else if oResponse.Format = ffXhtml then
        begin
          oComp := TFHIRXhtmlComposer.Create(oRequest.lang);
          TFHIRXhtmlComposer(oComp).BaseURL := AppendForwardSlash(oRequest.baseUrl);
          TFHIRXhtmlComposer(oComp).Session := oRequest.Session.Link;
          TFHIRXhtmlComposer(oComp).Tags := oResponse.categories.Link;
          TFHIRXhtmlComposer(oComp).relativeReferenceAdjustment := relativeReferenceAdjustment;
          TFHIRXhtmlComposer(oComp).OnGetLink := GetWebUILink;
          TFHIRXhtmlComposer(oComp).OperationName := oRequest.OperationName;
//          response.Expires := 0;
        response.Pragma := '';
        end
        else if oResponse.Format = ffXml then
          oComp := TFHIRXmlComposer.Create(oRequest.lang)
        else if oResponse.Resource._source_format = ffJson then
          oComp := TFHIRJsonComposer.Create(oRequest.lang)
        else
          oComp := TFHIRXmlComposer.Create(oRequest.lang);
        try
          response.ContentType := oComp.MimeType;
          oComp.Compose(stream, oResponse.resource, pretty, oresponse.link_List);
        finally
          oComp.Free;
        end;
      end;
    end
    else if oRequest.CommandType in [fcmdGetMeta, fcmdUpdateMeta, fcmdDeleteMeta] then
    begin
      response.Expires := Now; //don't want anyone caching anything
      assert(oResponse.Meta <> nil);
      response.Pragma := 'no-cache';
      if oResponse.Format = ffJson then
        oComp := TFHIRJsonComposer.Create(oRequest.lang)
      else if oResponse.Format = ffXhtml then
      begin
        oComp := TFHIRXhtmlComposer.Create(oRequest.lang);
        TFHIRXhtmlComposer(oComp).BaseURL := AppendForwardSlash(oRequest.baseUrl);
        TFHIRXhtmlComposer(oComp).Session := oRequest.Session.Link;
        TFHIRXhtmlComposer(oComp).Tags := oResponse.categories.Link;
        TFHIRXhtmlComposer(oComp).relativeReferenceAdjustment := relativeReferenceAdjustment;
        TFHIRXhtmlComposer(oComp).OnGetLink := GetWebUILink;
//          response.Expires := 0;
      response.Pragma := '';
      end
      else if oResponse.Format = ffXml then
        oComp := TFHIRXmlComposer.Create(oRequest.lang)
      else if oResponse.Resource._source_format = ffJson then
        oComp := TFHIRJsonComposer.Create(oRequest.lang)
      else
        oComp := TFHIRXmlComposer.Create(oRequest.lang);
      try
        response.ContentType := oComp.MimeType;
        oComp.Compose(stream, oResponse.Resource, pretty, oresponse.link_List);
      finally
        oComp.Free;
      end;
    end
    else
    begin
      if response.ContentType = '' then
        response.ContentType := 'text/plain';
      b := TEncoding.UTF8.GetBytes(oResponse.Body);
      stream.write(b, length(b));
    end;
    stream.Position := 0;
    if gzip and (stream.Size > 0) then
    begin
      response.ContentStream := TMemoryStream.Create;
      comp := TIdCompressorZLib.Create(nil);
      try
        comp.CompressStream(stream, response.ContentStream, 9, GZIP_WINBITS, 9, 0);
      finally
        comp.Free;
      end;
      response.ContentStream.Position := 0;
      response.ContentEncoding := 'gzip';
    end
    else
    begin
      response.ContentStream := stream;
      ownsStream := false;
    end;
  finally
    if ownsStream then
      stream.Free;
  end;
end;

function TFhirWebServer.processProvenanceHeader(header, lang: String): TFhirProvenance;
var
  json : TFHIRJsonParser;
  ss : TStringStream;
begin
  if header = '' then
    result := nil
  else
  begin
    ss := TStringStream.Create(header, TEncoding.UTF8);
    try
      json := TFHIRJsonParser.Create(lang);
      try
        json.source := ss;
        json.Parse;
        result := (json.resource as TFhirProvenance).Link;
      finally
        json.Free;
      end;
    finally
      ss.Free;
    end;
  end;
end;

function sNow : String;
begin
  result := FormatDateTime('c', now);
end;

procedure TFhirWebServer.ProcessRequest(request: TFHIRRequest; response: TFHIRResponse; upload : Boolean);
var
  store : TFhirOperationManager;
begin
  writelnt('Request: cmd='+CODES_TFHIRCommandType[request.CommandType]+', type='+CODES_TFhirResourceType[request.ResourceType]+', id='+request.Id+', user='+request.Session.Name+', params='+request.Parameters.Source);
  store := TFhirOperationManager.Create(request.Lang, FFhirStore.Link);
  try
    store.OwnerName := FOwnerName;
    store.OnPopulateConformance := PopulateConformance;
    store.Connection := FFhirStore.DB.GetConnection('Operation');
    try
      store.Connection.StartTransact;
      try
        store.Execute(request, response, upload);
        store.Connection.Commit;
      except
        store.Connection.Rollback;
        raise
      end;
      store.Connection.Release;
    except
      on e:exception do
      begin
        store.Connection.Error(e);
        raise;
      end;
    end;
  finally
    store.Free;
  end;
end;

procedure TFhirWebServer.ProcessScimRequest(AContext: TIdContext; request: TIdHTTPRequestInfo; response: TIdHTTPResponseInfo);
var
  sCookie : String;
  c : integer;
  session : TFhirSession;
  check : boolean;
begin
  if request.AuthUsername = 'Bearer' then
    sCookie := request.AuthPassword
  else
  begin
    c := request.Cookies.GetCookieIndex(FHIR_COOKIE_NAME);
    if c > -1 then
      sCookie := request.Cookies[c].CookieText.Substring(FHIR_COOKIE_NAME.Length+1);
  end;

  if (sCookie <> '') and request.Document.StartsWith('/scim/logout') then
  begin
    FFhirStore.EndSession(sCookie, request.RemoteIP);
    response.Redirect('/closed');
  end
  else if (FFhirStore.GetSession(sCookie, session, check)) then
  begin
    try
      if check and not CheckSessionOK(session, request.RemoteIP) then
        Raise ERestfulAuthenticationNeeded.Create('TFhirWebServer', 'HTTPRequest', GetFhirMessage('MSG_AUTH_REQUIRED', request.AcceptLanguage), 'Session Expired', HTTP_ERR_UNAUTHORIZED);
      if not session.canAdministerUsers then
        Raise ERestfulAuthenticationNeeded.Create('TFhirWebServer', 'HTTPRequest', GetFhirMessage('MSG_AUTH_REQUIRED', request.AcceptLanguage), 'This Session is not authorised to manage users', HTTP_ERR_UNAUTHORIZED);
      FSCIMServer.processRequest(acontext, request, response, session);
    finally
      session.Free;
    end;
  end
  else
    Raise ERestfulAuthenticationNeeded.Create('TFhirWebServer', 'HTTPRequest', GetFhirMessage('MSG_AUTH_REQUIRED', request.AcceptLanguage), 'Authentication required', HTTP_ERR_UNAUTHORIZED);
end;

function TFhirWebServer.BuildFhirAuthenticationPage(lang, host, path, msg : String; secure : boolean): String;
var
  authurl : string;
begin
  authurl := OAuthPath(secure);


result :=
'<?xml version="1.0" encoding="UTF-8"?>'#13#10+
'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"'#13#10+
'       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'#13#10+
''#13#10+
'<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">'#13#10+
'<head>'#13#10+
'    <title>FHIR RESTful Server - FHIR v'+FHIR_GENERATED_VERSION+'-'+FHIR_GENERATED_REVISION+'</title>'#13#10+
TFHIRXhtmlComposer.PageLinks+#13#10+
FHIR_JS+
'</head>'#13#10+
''#13#10+
'<body>'#13#10+
''#13#10+
TFHIRXhtmlComposer.Header(nil, FBasePath, lang)+
'<h2>'+FOwnerName+' '+GetFhirMessage('NAME_SERVER', lang)+'</h2>'#13#10;



result := result +
'<p>'#13#10+
GetFhirMessage('MSG_AUTH_REQUIRED', lang)+ '</p>'#13#10;
if msg <> '' then
result := result +
  '<p><b>'+ FormatTextToHTML(msg)+'</b></p>'#13#10;

result := result +
'<p><a href="/oauth2/auth?client_id=web&response_type=code&scope=openid%20profile%20user/*.*%20'+SCIM_ADMINISTRATOR+'&redirect_uri='+authurl+'/internal&aud='+authurl+'&state='+FAuthServer.MakeLoginToken(path, apGoogle)+'">Login using OAuth</a></p>'+#13#10;

result := result +
'<p>Or use the <a href="http://'+FHost+port(FPort, 80)+FBasePath+'">unsecured API</a>.</p>'#13#10+
'<p>&nbsp;</p>'#13#10+
'<p>This server uses <a href="http://fhir-docs.smarthealthit.org/argonaut-dev/authorization/">Smart on FHIR</a> for OAuth logins</p>'#13#10;
result := result +
TFHIRXhtmlComposer.Footer(lang, lang);

end;


function TFhirWebServer.BuildFhirHomePage(comps, lang, host, sBaseURL : String; session : TFhirSession; secure : boolean): String;
var
  counts : Array [TFHIRResourceType] of Integer;
  a : TFHIRResourceType;
  db : TKDBConnection;
  s : String;
  names : TStringList;
  profiles : TAdvStringMatch;
  i, j : integer;
  cmp : String;
  b : TStringBuilder;
  pol : String;
begin
  for a := low(TFHIRResourceType) to high(TFHIRResourceType) do
    if (comps = '') or (COMPARTMENT_PARAM_NAMES[frtPatient, a] <> '') then
      counts[a] := 0
    else
      counts[a] := -1;

  if (comps <> '') then
    cmp := ' and Ids.ResourceKey in (select ResourceKey from Compartments where CompartmentType = 1 and Id in ('+comps+'))'
  else
    cmp := '';

  pol := FFhirStore.ProfilesAsOptionList;
  profiles := TAdvStringMatch.create;
  try
    profiles.forced := true;
    if FFhirStore <> nil then
    begin
      db := FFhirStore.DB.GetConnection('fhir');
      try
        db.sql := 'select ResourceName, count(*) as Count from Ids,  Types where Ids.ResourceTypeKey = Types.ResourceTypeKey '+cmp+' group by ResourceName';

        db.prepare;
        db.execute;
        while db.fetchNext do
        begin
          j := StringArrayIndexOfSensitive(CODES_TFHIRResourceType, db.ColStringByname['ResourceName']);
          if j > -1 then
            counts[TFhirResourceType(j)] := db.ColIntegerByName['Count'];
        end;
        db.terminate;
        db.Release;
      except
        on e:exception do
        begin
          db.Error(e);
          raise;
        end;
      end;
    end;

   s := host+sBaseURL;
   b := TStringBuilder.Create;
   try
    b.Append(
  '<?xml version="1.0" encoding="UTF-8"?>'#13#10+
  '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"'#13#10+
  '       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'#13#10+
  ''#13#10+
  '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">'#13#10+
  '<head>'#13#10+
  '    <title>FHIR RESTful Server - FHIR v'+FHIR_GENERATED_VERSION+'-'+FHIR_GENERATED_REVISION+'</title>'#13#10+
  TFHIRXhtmlComposer.pagelinks+
  FHIR_JS+
  '</head>'#13#10+
  ''#13#10+
  '<body>'#13#10+
  TFHIRXhtmlComposer.Header(Session, sBaseURL, lang));

  b.Append(
  '<h2>'+FOwnerName+' '+GetFhirMessage('NAME_SERVER', lang)+'</h2>'#13#10);

    if session <> nil then
      if secure then
        b.Append('<p>Welcome '+FormatTextToXml(session.Name)+'</p>'#13#10)
      else
        b.Append('<p>Welcome '+FormatTextToXml(session.Name)+' (or use <a href="https://'+FHost+port(FSSLPort, 443)+FSecurePath+'">Secure API</a>)</p></p>'#13#10);

  b.Append(
  '<p>'#13#10+
  StringFormat(GetFhirMessage('MSG_HOME_PAGE_1', lang), ['<a href="http://hl7.org/fhir">http://hl7.org/fhir</a>'])+#13#10+
  StringFormat(GetFhirMessage('MSG_HOME_PAGE_2', lang), [s])+' This server defines some <a href="local.hts">extensions to the API</a>, and also offers <a href="/tx">Terminology Services</a>'+#13#10+
  '</p>'#13#10+
  '<hr/>'#13#10+
  ''#13#10+
  '<p>'+GetFhirMessage('SYSTEM_OPERATIONS', lang)+':</p><ul><li> <a href="'+sBaseUrl+'/metadata">'+GetFhirMessage('CONF_PROFILE', lang)+'</a> '+
   '('+GetFhirMessage('OR', lang)+' <a href="'+sBaseUrl+'/metadata?_format=text/xml">as xml</a> ('+GetFhirMessage('OR', lang)+' <a href="'+sBaseUrl+'/metadata?_format=application/json">JSON</a>)</li>'+#13#10+
  '<li><a class="tag" href="'+sBaseUrl+'/'+META_CMD_NAME+'">'+GetFhirMessage('SYSTEM_TAGS', lang)+'</a></li>'+
  '<li><a href="'+sBaseUrl+'/_search">'+GetFhirMessage('GENERAL_SEARCH', lang)+'</a></li>'+
  '<li><a href="'+sBaseUrl+'/_history">'+StringFormat(GetFhirMessage('MSG_HISTORY', lang), [GetFhirMessage('NAME_SYSTEM', lang)])+'</a> (History of all resources)</li>'+#13#10+
  '<li><a href="#upload">'+GetFhirMessage('NAME_UPLOAD_SERVICES', lang)+'</a></li>'+#13#10);

  b.Append(
  '<li>Create/Edit a new resource based on the profile: <form action="'+sBaseURL+'/_web/Create" method="GET"><select name="profile">'+pol+'</select> <input type="submit" value="GO"></form></li>'+#13#10);

  if (session.canAdministerUsers) then
    b.Append('<li><a href="/scim/web">Manage Users</a></li>'+#13#10);

  b.Append(
  '</ul>'+#13#10+
  ''#13#10+
  '<hr/>'#13#10+
  '<p>'+GetFhirMessage('MSG_HOME_PAGE_3', lang)+'</p>'+#13#10);


  b.Append(
  '<table class="lines">'#13#10+

             '<tr><th>'+GetFhirMessage('NAME_TYPE', lang)+'</th>'+
             '<th>'+GetFhirMessage('NAME_STORED', lang)+'</th>'+
             '<th colspan="4">'+GetFhirMessage('NAME_OPERATIONS', lang)+'</th><td style="border-left: 1px solid grey"/><th>'+GetFhirMessage('NAME_TYPE', lang)+'</th>'+
             '<th>'+GetFhirMessage('NAME_STORED', lang)+'</th>'+
             '<th colspan="4">'+GetFhirMessage('NAME_OPERATIONS', lang)+'</th></tr>'#13#10);

    names := TStringList.create;
    Try
      for a := TFHIRResourceType(1) to High(TFHIRResourceType) do
        if (counts[a] > -1) and (FFhirStore.ResConfig[a].Supported)  then
          names.Add(CODES_TFHIRResourceType[a]);

      names.Sort;
      j := 0;
      for i := 0 to names.count div 2 do
      begin
        inc(j);
        if j mod 2 = 1 then
          b.Append('<tr bgcolor="#F0F0F0">')
        else
          b.Append('<tr bgcolor="#FFFFFF">');

        a := TFHIRResourceType(StringArrayIndexOfSensitive(CODES_TFHIRResourceType, names[i]));
        b.Append(TFHIRXhtmlComposer.ResourceLinks(a, lang, sBaseUrl, counts[a], true, true, session.canRead(a)));

        b.Append('<td style="border-left: 1px solid grey"/>');

        if (i + names.count div 2) + 1 < names.count then
        begin
          a := TFHIRResourceType(StringArrayIndexOfSensitive(CODES_TFHIRResourceType, names[1 + i + names.count div 2]));
          b.Append(TFHIRXhtmlComposer.ResourceLinks(a, lang, sBaseUrl, counts[a], true, true, session.canRead(a)));
        end;

        b.Append('</tr>');

      end;
    finally
      names.free;
    end;
    b.Append(
  '</table>'#13#10+
  '<hr/><h2>'+GetFhirMessage('NAME_UPLOAD_SERVICES', lang)+'</h2>'#13#10+
  '<a name="upload"> </a><form enctype="multipart/form-data" method="POST">'+#13#10+
  '<p><input type="hidden" name="_format" value="text/html"/><br/>'+#13#10+
  ''+GetFhirMessage('MSG_CONTENT_MESSAGE', lang)+'.<br/><br/>'+#13#10+
  ''+GetFhirMessage('MSG_CONTENT_UPLOAD', lang)+': <br/><input type="file" name="file" size="60"/><br/>'+#13#10+
  ''+GetFhirMessage('MSG_CONTENT_PASTE', lang)+':<br/> <textarea name="src" cols="70" rows="5"/>'+#13#10+
  '</textarea><br/><br/>'+#13#10+
  '<table class="none"><tr><td>Operation:</td><td> <select size="1" name="op">'+#13#10+
  ' <option value="transaction">Transaction</option>'+#13#10+
  ' <option value="validation">Validation</option>'+#13#10+
  ' <option value="mailbox">MailBox Submission</option>'+#13#10+
  '</select></td></tr>'+#13#10+
  '<tr><td>Profile:</td><td> <select size="1" name="profile">'+#13#10+
  '<option value=""></option>'+#13#10+
  pol+
  '</select> (if validating, use the selected profile)</td></tr></table><br/>'+#13#10+
  '<input type="submit" value="'+GetFhirMessage('NAME_UPLOAD', lang)+'"/>'#13#10+
  '</p></form>'#13#10+
  TFHIRXhtmlComposer.footer(sBaseURL, lang));
  result := b.ToString;
   finally
     b.Free;
   end;
  finally
    profiles.free;
  end;
end;

function TFhirWebServer.BuildFhirUploadPage(lang, host, sBaseURL : String; aType : TFHIRResourceType; session : TFhirSession): String;
var
  s : String;
begin
  s := host+sBaseURL;

  result :=
'<?xml version="1.0" encoding="UTF-8"?>'#13#10+
'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"'#13#10+
'       "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'#13#10+
''#13#10+
'<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">'#13#10+
'<head>'#13#10+
'    <title>'+StringFormat(GetFhirMessage('UPLOAD', lang), [CODES_TFHIRResourceType[aType]])+'</title>'#13#10+
'    <link rel="Stylesheet" href="/css/fhir.css" type="text/css" media="screen" />'#13#10+
FHIR_JS+
'</head>'#13#10+
''#13#10+
'<body>'#13#10+
''#13#10+
'<div class="header">'#13#10+
'  <a href="http://www.hl7.org/fhir" title="'+GetFhirMessage('MSG_HOME_PAGE_TITLE', lang)+'"><img border="0" src="/img/flame16.png" style="vertical-align: text-bottom"/> <b>FHIR</b></a>'#13#10+
''#13#10+
'  &copy; HL7.org 2011-2013'#13#10+
'  &nbsp;'#13#10+
'  '+FOwnerName+' '+GetFhirMessage('NAME_SERVER', lang)+''#13#10+
'  &nbsp;'#13#10+
'  FHIR '+GetFhirMessage('NAME_VERSION', lang)+' '+FHIR_GENERATED_VERSION+'-'+FHIR_GENERATED_REVISION+''#13#10;

if session <> nil then
  result := result +'&nbsp;&nbsp;'+FormatTextToXml(Session.Name);

result := result +
'  &nbsp;<a href="'+s+'">'+GetFhirMessage('MSG_BACK_HOME', lang)+'</a>'#13#10+
'</div>'#13#10+
''#13#10+
'<div id="div-cnt" class="content">'#13#10+
'<h2>'+StringFormat(GetFhirMessage('UPLOAD', lang), [CODES_TFHIRResourceType[aType]])+'</h2>'#13#10+
'<form action="'+s+lowercase(CODES_TFHIRResourceType[aType])+'/upload" enctype="multipart/form-data" method="POST">'+#13#10+
'<input type="hidden" name="format" size="text/html"/><br/>'+#13#10+
''+GetFhirMessage('MSG_CONTENT_UPLOAD', lang)+': <input type="file" name="file" size="60"/><br/>'+#13#10+
'<input type="submit" value="Upload"/>'#13#10+
'</form>'#13#10+
''#13#10+
'<p><br/><a href="'+s+'">'+GetFhirMessage('MSG_BACK_HOME', lang)+'</a></p>'+
'</div>'#13#10+
'</body>'#13#10+
'</html>'#13#10+
''#13#10
end;


function TFhirWebServer.loadMultipartForm(const request : TStream; const contentType : String) : TIdSoapMimeMessage;
var
  m : TIdSoapMimeMessage;
begin
  m := TIdSoapMimeMessage.Create;
  Try
    m.ReadFromStream(request, contentType);
    result := m;
  Except
    m.free;
    raise;
  End;
end;

function TFhirWebServer.LookupReference(context: TFHIRRequest; id: String): TResourceWithReference;
var
  store : TFhirOperationManager;
begin
  store := TFhirOperationManager.Create(TFHIRRequest(context).Lang, FFhirStore.Link);
  try
    store.OwnerName := FOwnerName;
    store.Connection := FFhirStore.DB.GetConnection('Operation');
    try
      result := store.LookupReference(context, id);
      store.Connection.Release;
    except
      on e:exception do
      begin
        store.Connection.Error(e);
        raise;
      end;
    end;
  finally
    store.Free;
  end;
end;

function TFhirWebServer.MarkEntry(AContext: TIdContext; request: TIdHTTPRequestInfo; response: TIdHTTPResponseInfo): integer;
var
  s : string;
begin
  s := AContext.Binding.PeerIP + ' ' + request.Document+'?'+request.UnparsedParams;
  FLock.Lock;
  try
     inc(FLastTrack);
     result := FLastTrack;
     FTracks.Add(inttostr(result), s);
  finally
    FLock.Unlock;
  end;
end;

procedure TFhirWebServer.MarkExit(track: integer);
begin
  FLock.Lock;
  try
     FTracks.Remove(inttostr(track));
  finally
    FLock.Unlock;
  end;
end;

function TFhirWebServer.extractFileData(form : TIdSoapMimeMessage; const name: String; var sContentType : String): TStream;
var
  sLeft, sRight: String;
  iLoop : Integer;
  oPart : TIdSoapMimePart;
  sHeader : String;
  sName : String;
  sFilename : String;
  sContent : String;
begin
  result := nil;
  For iLoop := 0 To form.Parts.Count - 1 Do
  Begin
    oPart := form.Parts.PartByIndex[iLoop];
    sHeader := oPart.ContentDisposition;
    StringSplit(sHeader, ';', sLeft, sHeader);
    If trim(sLeft) = 'form-data' Then
    Begin
      StringSplit(Trim(sHeader), ';', sLeft, sHeader);
      StringSplit(Trim(sLeft), '=', sLeft, sRight);
      If Trim(sLeft) = 'name' Then
        sName := RemoveQuotes(Trim(sRight));
      StringSplit(Trim(sHeader), '=', sLeft, sRight);
      If Trim(sLeft) = 'filename' Then
        sFileName := RemoveQuotes(Trim(sRight));
      If (result = nil) and (sName <> '') And (sFileName <> '') And (oPart.Content.Size > 0) Then
      begin
        result := TBytesStream.Create(StreamToBytes(oPart.Content));
        sContentType := oPart.Mediatype;
      end
      else if (result = nil) and (sName = 'src') then
      begin
        sContent := BytesAsString(StreamToBytes(oPart.Content));
        result := TStringStream.create(StreamToBytes(oPart.Content)); // trim
        if StringStartsWith(sContent, '<', false) then
          sContentType := 'application/xml'
        else if StringStartsWith(sContent, '{', false) then
          sContentType := 'application/json'
        else
          raise exception.create('unable to determine encoding type for '+sContent);
      end;
    End
  End;
end;

function TFhirWebServer.GetResource(session : TFhirSession; rtype: TFhirResourceType; lang, id, ver, op: String): TFhirResource;
var
  request : TFHIRRequest;
  response : TFHIRResponse;
begin
  request := TFHIRRequest.create;
  response := TFHIRResponse.Create;
  try
    request.Session := session.link;
    request.ResourceType := rType;
    request.Lang := lang;
    request.Id := id;
    request.LoadParams('');
    if (op <> '') then
    begin
      request.CommandType := fcmdOperation;
      request.OperationName := op;
    end
    else if (ver = '') then
      request.CommandType := fcmdRead
    else
    begin
      request.CommandType := fcmdVersionRead;
      request.SubId := ver;
    end;
    ProcessRequest(request, response, false);
    if response.Resource <> nil then
      result := response.resource.link
    else
      raise Exception.Create('Unable to find resource '+CODES_TFhirResourceType[rtype]+'/'+id+'/'+ver);
  finally
    response.free;
    request.Free;
  end;
end;

function TFhirWebServer.FindResource(session : TFhirSession; rtype: TFhirResourceType; lang, params: String; var id : String): TFhirResource;
var
  request : TFHIRRequest;
  response : TFHIRResponse;
begin
  request := TFHIRRequest.create;
  response := TFHIRResponse.Create;
  try
    request.Session := session.link;
    request.ResourceType := rType;
    request.Lang := lang;
    request.LoadParams(params);
    request.CommandType := fcmdSearch;
    ProcessRequest(request, response, false);
    if (response.Feed <> nil) and (response.Feed.entryList.Count = 1) then
    begin
      result := response.feed.entryList[0].resource.link;
      id := response.feed.entryList[0].Resource.id.Substring(response.feed.entryList[0].Resource.id.LastIndexOf('/'));
    end
    else
      raise Exception.Create('Unable to find resource '+CODES_TFhirResourceType[rtype]+'?'+params);
  finally
    response.free;
    request.Free;
  end;
end;

procedure TFhirWebServer.GetWebUILink(resource: TFhirResource; base, statedType, id, ver: String; var link, text: String);
var
  tail : String;
begin
  link := '';
  if (resource <> nil) and (id <> '') then
  begin
    tail := id;
    if ver <> '' then
      tail := tail + '/' + ver;
    if resource.ResourceType = frtQuestionnaire then
    begin
      text := 'Try out the Questionnaire as a web form';
      if statedType = 'Profile'  then
        link := FBasePath+'/_web/Profile/'+tail
      else
        link := FBasePath+'/_web/Questionnaire/'+tail;
    end;
    if resource.ResourceType = frtStructureDefinition then
    begin
      link := FBasePath+'/_web/Profile/'+tail;
      text := 'Try out the Profile as a questionnaire based web form';
    end;
    if resource.ResourceType = frtValueSet then
    begin
      link := FBasePath+'/ValueSet/'+id+'/$expand?filter=';
      text := 'Expand this value set';
    end;
    if resource.ResourceType = frtPatient then
    begin
      link := FBasePath+'/_web/Patient/'+id;
      text := 'Patient Record Page';
    end;
  end;
end;

function TFhirWebServer.OAuthPath(secure: boolean): String;
begin
  if secure then
  begin
    if FSSLPort = 443 then
      result := 'https://'+FHost+FSecurePath
    else
      result := 'https://'+FHost+':'+inttostr(FSSLPort)+FSecurePath;
  end
  else
  begin
    if FPort = 80 then
      result := 'http://'+FHost+FSecurePath
    else
      result := 'http://'+FHost+':'+inttostr(FPort)+FSecurePath;
  end;
end;

function HashPword(s : String): AnsiString;
var
  hash : TDCP_sha256;
  res : TBytes;
begin
  result := '';
  hash := TDCP_sha256.Create(nil);
  try
    hash.Init;
    hash.UpdateStr(s);
    SetLength(res, hash.GetHashSize div 8);
    hash.Final(res[0]);
  finally
    hash.free;
  end;
  result := EncodeHexadecimal(res);
end;

constructor ERestfulAuthenticationNeeded.Create(const sSender, sMethod, sReason, sMsg: String; aStatus : Word);
begin
  Create(sSender, sMethod, sReason, aStatus);
  FMsg := sMsg;
end;


function TFhirWebServer.CheckSessionOK(session: TFhirSession; ip : string): Boolean;
var
  id, name, email, msg : String;
begin
  if session.provider = apGoogle then
    result := GoogleGetDetails(session.InnerToken, FAuthServer.GoogleAppKey, '', id, name, email, msg)
  else if session.provider = apFacebook then
    result := FacebookGetDetails(session.InnerToken, id, name, email, msg)
  else
    result := false;
  if result then
    result := session.Id = id;
  if result then
    FFhirStore.MarkSessionChecked(session.Cookie, session.Name)
  else
    FFhirStore.EndSession(session.Cookie, ip);
end;

procedure TFhirWebServer.ReadTags(Headers: TIdHeaderList; Request: TFHIRRequest);
var
  i : integer;
begin
  for i := 0 to Headers.Count - 1 do
    if Headers.Names[i] = 'Category' then
      ReadTags(Headers.Strings[i], Request);
end;

Procedure TFhirWebServer.ReadTags(header : String; Request : TFHIRRequest);
//var
//  s, s1, l, r, n, v : string;
//  cat : TFHIRAtomCategory;
begin
 // raise Exception.Create('todo');
end;


procedure TFhirWebServer.ReturnProcessedFile(response: TIdHTTPResponseInfo; session : TFhirSession; named, path: String; secure : boolean; variables: TDictionary<String, String> = nil);
var
  s, n : String;
begin
  writelnt('script: '+named);
  s := FileToString(path, TEncoding.UTF8);
  s := s.Replace('[%id%]', FName, [rfReplaceAll]);
  s := s.Replace('[%ver%]', FHIR_GENERATED_VERSION+'-'+FHIR_GENERATED_REVISION, [rfReplaceAll]);
  s := s.Replace('[%web%]', WebDesc, [rfReplaceAll]);
  s := s.Replace('[%admin%]', FAdminEmail, [rfReplaceAll]);
  if (session = nil) then
    s := s.Replace('[%logout%]', 'User: [n/a]', [rfReplaceAll])
  else
    s := s.Replace('[%logout%]', '|&nbsp;User: '+session.Name+'&nbsp; <a href="/closed/logout" title="Log Out"><img src="/logout.png"></a>  &nbsp;', [rfReplaceAll]);
  if FPort = 80 then
    s := s.Replace('[%host%]', FHost, [rfReplaceAll])
  else
    s := s.Replace('[%host%]', FHost+':'+inttostr(FPort), [rfReplaceAll]);
  if FSSLPort = 443 then
    s := s.Replace('[%securehost%]', FHost, [rfReplaceAll])
  else
    s := s.Replace('[%securehost%]', FHost+':'+inttostr(FSSLPort), [rfReplaceAll]);
  if s.Contains('[%fitbit-redirect%]') then
    s := s.Replace('[%fitbit-redirect%]', FitBitInitiate(
       FAuthServer.Ini.ReadString('fitbit', 'secret', ''), // secret,
       FAuthServer.Ini.ReadString('fitbit', 'key', ''), //key
       GUIDToString(CreateGUID), //nonce
       'https://local.healthintersections.com.au:961/closed/_web/fitbit.html') //callback
    , [rfReplaceAll]);

  s := s.Replace('[%endpoints%]', EndPointDesc(secure), [rfReplaceAll]);
  if variables <> nil then
    for n in variables.Keys do
      s := s.Replace('[%'+n+'%]', variables[n], [rfReplaceAll]);

  response.Expires := now + 1;
  response.ContentStream := TBytesStream.Create(TEncoding.UTF8.GetBytes(s));
  response.FreeContentStream := true;
  response.ContentType := 'text/html; charset=UTF-8';
end;

procedure TFhirWebServer.ReturnSpecFile(response : TIdHTTPResponseInfo; stated, path: String);
begin
  writelnt('file: '+stated);
  response.Expires := now + 1;
  response.ContentStream := TFileStream.Create(path, fmOpenRead);
  response.FreeContentStream := true;
  response.ContentType := GetMimeTypeForExt(ExtractFileExt(path));
end;

//procedure TFhirWebServer.DoSendFHIR(iMsgKey, SrcID: Integer; request: TFHIRRequest; response: TFHIRResponse);
//var
//  client : TFHIRClient;
//begin
//  client := TFhirClient.create(FBaseURL, false);
//  try
//    FClientLock.Lock('MakeClient');
//    Try
//      FClients.Add(client);
//    Finally
//      FClientLock.Unlock;
//    End;
//    try
//      if (request.CommandType = fcmdUpdate) and (request.id = '') then
//        request.id := 'test';
//
//      client.doRequest(request, response);
//    finally
//      FClientLock.Lock('CloseClient');
//      Try
//        FClients.Remove(client);
//            Finally
//        FClientLock.Unlock;
//      End;
//    end;
//  finally
//    client.free;
//  end;
//end;
//
function TFhirWebServer.BuildCompartmentList(session: TFHIRSession): String;
  function tail(s : String):String;
  begin
    result := copy(s, 10, $FF);
  end;
var
  i : integer;
begin
  result := ''''+tail(session.patientList[0])+'''';
  for i := 1 to session.patientList.count - 1 do
    result := result+', '''+tail(session.patientList[i])+'''';
  for i := 0 to session.TaggedCompartments.count - 1 do
    result := result+', '''+session.TaggedCompartments[i]+'''';
end;

{ TFhirServerMaintenanceThread }

constructor TFhirServerMaintenanceThread.create(server: TFHIRWebServer);
begin
  FreeOnTerminate := true;
  FServer := server;
  FLastSweep := now;
  inherited Create;
end;

procedure TFhirServerMaintenanceThread.Execute;
begin
  CoInitialize(nil);
  repeat
    sleep(1000);
    if FServer.FActive then
      FServer.FFhirStore.ProcessSubscriptions;
    if (not terminated) then
    begin
      try
        FServer.FFhirStore.TerminologyServer.BuildIndexes(false);
      except
      end;
    end;
    if not terminated and (FLastSweep < now - (DATETIME_SECOND_ONE * 5)) then
    begin
      try
        FServer.FFhirStore.Sweep;
      except
      end;
      FLastSweep := now;
    end;
  until Terminated;
  CoUninitialize;
end;

function TFhirWebServer.transform1(resource: TFhirResource; lang, xslt: String; saveOnly : boolean): string;
var
  xml : TFHIRXmlComposer;
  msx : TMsXmlParser;
  b : TBytesStream;
  v: variant;
  doc, src : IXMLDOMDocument2;
  xform: IXSLTemplate;
  proc : IXSLProcessor;
  url : String;
begin
//  result := transform2(resource, lang, xslt);
//  exit;

  b := TBytesStream.Create;
  try
    xml := TFHIRXmlComposer.Create(lang);
    try
      xml.Compose(b, resource, false, nil);
    finally
      xml.Free;
    end;
    b.position := 0;
    msx := TMsXmlParser.Create;
    try
      doc := msx.Parse(b);
    finally
      msx.free;
    end;
  finally
    b.Free;
  end;
  writelnt(doc.documentElement.namespaceURI +', '+doc.documentElement.nodeName);

  v := CreateOLEObject('MSXML2.FreeThreadedDOMDocument.6.0');
  src := IUnknown(TVarData(v).VDispatch) as IXMLDomDocument2;
  src.async := false;
  src.resolveExternals := false;
  src.validateOnParse := false;
  src.setProperty('AllowDocumentFunction', True);
  if not src.loadXML(FileToString(xslt, TEncoding.UTF8)) then
    raise Exception.Create('unable to parse XSLT: '+src.parseError.reason);

  v := CreateOLEObject('MSXML2.XSLTemplate.6.0');
  xform := IUnknown(TVarData(v).VDispatch) as IXSLTemplate;
  xform.stylesheet := src;

  Proc := xform.createProcessor;
  Proc.Input := doc;
  Proc.addParameter('useMicrosoft', 'true', '');

  if FPort <> 0 then
    url := 'http://'+FHost+':'+inttostr(FPort)
  else
    url := 'https://'+FHost+':'+inttostr(FSSLPort);

  if saveOnly then
    Proc.addParameter('saveOnly', 'true', '');

  Proc.addParameter('expansionServer', url+FBasePath, '');
  Proc.addParameter('iconPath', url, '');
  Proc.addParameter('jQueryPath', url+'/js', '');

  Proc.Transform;
  result := Proc.Output;
end;


//function TFhirWebServer.transform2(resource: TFhirResource; lang, xslt: String): string;
//var
//  xslt2: AltovaXMLLib_TLB.XSLT2;
//  xml : TFHIRXmlComposer;
//  s : String;
//  AltovaXml : AltovaXMLLib_TLB.Application;
//begin
//  xml := TFHIRXmlComposer.Create(lang);
//  try
//    s := xml.Compose('', '', '', resource, false, nil);
//  finally
//    xml.Free;
//  end;
//
//  AltovaXml := AltovaXMLLib_TLB.CoApplication.Create;
//  xslt2 := AltovaXml.XSLT2;
//  xslt2.InputXMLFromText := s;
//  xslt2.XSLFileName := xslt;
//  result := xslt2.ExecuteAndGetResultAsString;
//  xslt2 := nil;
//  AltovaXml := nil;
//end;

Initialization
  IdSSLOpenSSLHeaders.Load;
End.






