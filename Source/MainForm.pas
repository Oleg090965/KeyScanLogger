unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, System.IOUtils;

type
  // Объявляем структуры хука клавиатуры
  PKBDLLHOOKSTRUCT = ^TKBDLLHOOKSTRUCT;
  TKBDLLHOOKSTRUCT = packed record
    vkCode: DWORD;
    scanCode: DWORD;
    flags: DWORD;
    time: DWORD;
    dwExtraInfo: ULONG_PTR;
  end;

  TfrmMain = class(TForm)
    memoLog: TMemo;
    Panel1: TPanel;
    btnStart: TButton;
    btnStop: TButton;
    btnClear: TButton;
    chkLogToFile: TCheckBox;
    StatusBar: TStatusBar;
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
    FKeyboardHook: HHook;
    FLogFile: TextFile;
    FIsLogging: Boolean;
    function LowLevelKeyboardProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT;
    function GetKeyName(vkCode: DWORD; scanCode: DWORD): string;
    procedure LogToFile(const Message: string);
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

// Глобальная callback функция должна быть объявлена отдельно
function KeyboardHookProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  if Assigned(frmMain) then
    Result := frmMain.LowLevelKeyboardProc(nCode, wParam, lParam)
  else
    Result := CallNextHookEx(0, nCode, wParam, lParam);
end;

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FKeyboardHook := 0;
  FIsLogging := False;

  // Инициализация файла лога
  AssignFile(FLogFile, 'keyscan_log.txt');
  if FileExists('keyscan_log.txt') then
    Append(FLogFile)
  else
    Rewrite(FLogFile);

  WriteLn(FLogFile, '===  KeyScan Logger Started at ' + DateTimeToStr(Now) + ' ===');
  CloseFile(FLogFile);

  Caption := ' KeyScan Logger - Windows 10/11';
  StatusBar.SimpleText := 'Готов к работе. Нажмите "Старт" для начала записи.';
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  if FKeyboardHook <> 0 then
    UnhookWindowsHookEx(FKeyboardHook);
end;

function TfrmMain.LowLevelKeyboardProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  kbdStruct: PKBDLLHOOKSTRUCT;
  KeyName: string;
  LogMessage: string;
begin
  Result := CallNextHookEx(FKeyboardHook, nCode, wParam, lParam);

  if nCode = HC_ACTION then
  begin
    kbdStruct := PKBDLLHOOKSTRUCT(lParam);

    if (wParam = WM_KEYDOWN) or (wParam = WM_SYSKEYDOWN) then
    begin
      KeyName := GetKeyName(kbdStruct.vkCode, kbdStruct.scanCode);

      LogMessage := Format('Клавиша: %-15s | Скан-код: 0x%.2x | VK_CODE: 0x%.2x | Время: %d | Флаги: %.2x',
        [KeyName, kbdStruct.scanCode, kbdStruct.vkCode, kbdStruct.time, kbdStruct.flags]);

      // Вывод в Memo
      TThread.Queue(nil, procedure
        begin
          if memoLog.Lines.Count > 1000 then
            memoLog.Lines.Clear;
          memoLog.Lines.Add(LogMessage);
          memoLog.SelStart := Length(memoLog.Text);
        end);

      // Запись в файл
      if chkLogToFile.Checked then
        LogToFile(LogMessage);
    end;
  end;
end;

function TfrmMain.GetKeyName(vkCode: DWORD; scanCode: DWORD): string;
var
  KeyName: array[0..255] of Char;
  lParam: LONG;
begin
  Result := '';

  // Получаем имя клавиши через WinAPI
  lParam := scanCode shl 16;
  if GetKeyNameText(lParam, KeyName, SizeOf(KeyName)) > 0 then
    Result := KeyName
  else
  begin
    // Базовые клавиши
    case vkCode of
      VK_SPACE:    Result := 'Space';
      VK_RETURN:   Result := 'Enter';
      VK_BACK:     Result := 'Backspace';
      VK_TAB:      Result := 'Tab';
      VK_ESCAPE:   Result := 'Escape';
      VK_CONTROL:  Result := 'Ctrl';
      VK_SHIFT:    Result := 'Shift';
      VK_MENU:     Result := 'Alt';
      VK_CAPITAL:  Result := 'CapsLock';
      VK_LWIN:     Result := 'Left Win';
      VK_RWIN:     Result := 'Right Win';
      VK_APPS:     Result := 'Menu';
      VK_INSERT:   Result := 'Insert';
      VK_DELETE:   Result := 'Delete';
      VK_HOME:     Result := 'Home';
      VK_END:      Result := 'End';
      VK_PRIOR:    Result := 'Page Up';
      VK_NEXT:     Result := 'Page Down';
      VK_UP:       Result := 'Up Arrow';
      VK_DOWN:     Result := 'Down Arrow';
      VK_LEFT:     Result := 'Left Arrow';
      VK_RIGHT:    Result := 'Right Arrow';
      VK_NUMLOCK:  Result := 'NumLock';
      VK_SCROLL:   Result := 'ScrollLock';
      VK_PAUSE:    Result := 'Pause';
      VK_SNAPSHOT: Result := 'PrintScreen';
      VK_F1:       Result := 'F1';
      VK_F2:       Result := 'F2';
      VK_F3:       Result := 'F3';
      VK_F4:       Result := 'F4';
      VK_F5:       Result := 'F5';
      VK_F6:       Result := 'F6';
      VK_F7:       Result := 'F7';
      VK_F8:       Result := 'F8';
      VK_F9:       Result := 'F9';
      VK_F10:      Result := 'F10';
      VK_F11:      Result := 'F11';
      VK_F12:      Result := 'F12';
      else          Result := 'Unknown 0x' + IntToHex(vkCode, 2);
    end;
  end;
end;

procedure TfrmMain.LogToFile(const Message: string);
begin
  TThread.Queue(nil, procedure
    begin
      try
        Append(FLogFile);
        WriteLn(FLogFile, FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' | ' + Message);
        CloseFile(FLogFile);
      except
        on E: Exception do
          StatusBar.SimpleText := 'Ошибка записи в файл: ' + E.Message;
      end;
    end);
end;

procedure TfrmMain.btnStartClick(Sender: TObject);
begin
  if FKeyboardHook = 0 then
  begin
    // Установка низкоуровневого хука на клавиатуру
    FKeyboardHook := SetWindowsHookEx(WH_KEYBOARD_LL, @KeyboardHookProc, HInstance, 0);

    if FKeyboardHook = 0 then
    begin
      MessageDlg('Ошибка: Не удалось установить хук клавиатуры!', mtError, [mbOK], 0);
      Exit;
    end;

    FIsLogging := True;
    Timer.Enabled := True;
    btnStart.Enabled := False;
    btnStop.Enabled := True;
    StatusBar.SimpleText := 'Запись активна. Нажимайте клавиши...';

    memoLog.Lines.Add('=== Запись начата ' + DateTimeToStr(Now) + ' ===');

    if chkLogToFile.Checked then
    begin
      Append(FLogFile);
      WriteLn(FLogFile, '=== Recording Started at ' + DateTimeToStr(Now) + ' ===');
      CloseFile(FLogFile);
    end;
  end;
end;

procedure TfrmMain.btnStopClick(Sender: TObject);
begin
  if FKeyboardHook <> 0 then
  begin
    UnhookWindowsHookEx(FKeyboardHook);
    FKeyboardHook := 0;
    FIsLogging := False;
    Timer.Enabled := False;
    btnStart.Enabled := True;
    btnStop.Enabled := False;
    StatusBar.SimpleText := 'Запись остановлена.';

    memoLog.Lines.Add('=== Запись остановлена ' + DateTimeToStr(Now) + ' ===');

    if chkLogToFile.Checked then
    begin
      Append(FLogFile);
      WriteLn(FLogFile, '=== Recording Stopped at ' + DateTimeToStr(Now) + ' ===');
      CloseFile(FLogFile);
    end;
  end;
end;

procedure TfrmMain.btnClearClick(Sender: TObject);
begin
  memoLog.Clear;
  StatusBar.SimpleText := 'Лог очищен.';
end;

procedure TfrmMain.TimerTimer(Sender: TObject);
begin
  // Проверка нажатия ESC для быстрого выхода
  if GetAsyncKeyState(VK_ESCAPE) < 0 then
  begin
    if FIsLogging then
      btnStopClick(Self);
  end;
end;

end.
