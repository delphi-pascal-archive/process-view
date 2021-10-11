unit uPView;
// Simple process view programm
// For generate programm list use ProcessID (PID)
// This method view all hiden processe's in UserMode

// Author: BlackCash
// eMail : BlackCash2006@Yandex.ru
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Psapi, ExtCtrls, ShellApi;

type
  TForm1 = class(TForm)
    ListView1: TListView;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
    procedure Label2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Label1MouseLeave(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ListView1CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure Label2Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

function EnablePrivilege(Process: dword; lpPrivilegeName: PChar):Boolean;
var
  hToken: dword;
  NameValue: Int64;
  tkp: TOKEN_PRIVILEGES;
  ReturnLength: dword;
begin
  Result:=false;
  OpenProcessToken(Process, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken);
  if not LookupPrivilegeValue(nil, lpPrivilegeName, NameValue) then
    begin
     CloseHandle(hToken);
     exit;
    end;
  tkp.PrivilegeCount := 1;
  tkp.Privileges[0].Luid := NameValue;
  tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
  AdjustTokenPrivileges(hToken, false, tkp, SizeOf(TOKEN_PRIVILEGES), tkp, ReturnLength);
  if GetLastError() <> ERROR_SUCCESS then
     begin
      CloseHandle(hToken);
      exit;
     end;
  Result:=true;
  CloseHandle(hToken);
end;

function FixProcessPath(PPath: String): String;
begin
  if PPath = '?' then begin
    Result := '';
    Exit;
  end;
  if Pos('\??\',PPath) <> 0 then begin
    Result := Copy(PPath,5,length(PPath));
  end else Result := PPath;
end;

function GetPathByPID(hProcess: THandle) : string;
  var
  cb: DWORD;
  hMod: HMODULE;
  ModuleName: array [0..300] of Char;  
begin  
  if (hProcess <> 0) then
  begin
    EnumProcessModules(hProcess, @hMod, SizeOf(hMod), cb);
    GetModuleFilenameEx(hProcess, hMod, ModuleName, SizeOf(ModuleName));
    if FileExists( FixProcessPath (ModuleName)) then
      Result := (ModuleName);
  end;
end;

Function Exist_inList(PList: TStrings; PRecord: string): boolean;
var
  i: integer;
begin
  Result := False;
  for i := 0 to PList.Count-1 do
    if LowerCase(PList[i]) = LowerCase(PRecord) then
    begin
      Result := true;
      Exit;
    end;
end;
{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  i: cardinal;
  hProcess: cardinal;
  path: string;
  PID: integer;
  sList: TStringList;
begin
  EnablePrivilege(INVALID_HANDLE_VALUE, 'SeDebugPrivilege');
  //
  sList := TStringList.Create;
  ListView1.Clear;
  i := 0;
  While i < 20000 do begin
    hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, false, i);
    if hProcess > 0 then begin
      PID  := i;
      path := FixProcessPath(getPathbyPID(hProcess));
      CloseHandle(hProcess);
      if path <> '' then
      if not Exist_inList(sList,path) then
      begin
        sList.Add(path);
        with ListView1.Items.Add do begin
          Caption := ExtractFileName(Path);
          SubItems.Add(IntToStr(PID));
          SubItems.Add(path);
        end;
      end;
    end else CloseHandle(hProcess);
    inc(i);
  end;
  sList.Free;
end;

procedure TForm1.Label2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  with (sender as tLabel).Font do
    Color := clBlue;
end;

procedure TForm1.Label1MouseLeave(Sender: TObject);
begin
  with (sender as tLabel).Font do
    Color := clBLack;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
 Item: TListItem;
 hProcess: integer;
begin
 Item := ListView1.Selected;
 if Item <> nil then
   begin
    hProcess := OpenProcess(PROCESS_TERMINATE, false, StrToInt(Item.SubItems.Strings[0]));
    if hProcess > 0 then
     begin
       TerminateProcess(hProcess, 0);
       CloseHandle(hProcess);
     end else ShowMessage('Error unload process!');
   end;
end;

procedure TForm1.Button4Click(Sender: TObject);
const
  R = #13#10;
begin
  MessageDlg('Process View                   '
  +r+r+'Author: BlackCash'+r
  +'eMail: BlackCash2006@Yandex.ru'
  ,mtInformation,[mbOK],0);
end;

procedure TForm1.ListView1CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  with ListView1.Canvas.Brush do
  begin
    case Item.Index mod 2 of
      1: Color := $00DEE2E4;
      0: Color := clWhite;
    end;
  end;
end;

procedure TForm1.Label2Click(Sender: TObject);
begin
ShellExecute(0,'open','http://www.stopvirus.ru','','',1);
end;

procedure TForm1.Label1Click(Sender: TObject);
begin
  shellexecute(handle,
  'Open',
  'mailto:BlackCash2006@Yandex.ru?subject=x-Core Process Spy',
  nil, nil, sw_restore); 
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
Close;
end;

end.
