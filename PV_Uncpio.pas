unit PV_Uncpio;

{$mode objfpc}{$H+}

//PV Unpack
//https://github.com/PascalVault
//Licence: MIT
//Last update: 2023-09-18
//GNU CPIO "new ascii"

interface

uses
  Classes, SysUtils, PV_Unpack, Math, Dialogs;

  { TUnPak }

type
  TUncpio = class(TUnpack)
  public
    constructor Create(Str: TStream); override;
  end;


implementation

{ TUntar }

constructor TUncpio.Create(Str: TStream);
type TEntry = packed record
       Magic: array[0..5] of Char;//`070701'
       Ino: array[0..7] of Char;
       Mode: array[0..7] of Char;
       UID: array[0..7] of Char;
       GID: array[0..7] of Char;
       Nlink: array[0..7] of Char;
       MTime: array[0..7] of Char;
       Filesize: array[0..7] of Char;
       Devmajor: array[0..7] of Char;
       Devminor: array[0..7] of Char;
       Rdevmajor: array[0..7] of Char;
       Rdevminor: array[0..7] of Char;
       FNameSize: array[0..7] of Char;
       Check: array[0..7] of Char;
       //total 110 bytes
    end;

var Entry: TEntry;
    i: Integer;
    FName: String;
    FNameLen: Integer;
    PackSize: Cardinal;
begin
  FStream := Str;

  try
    FSize  := 1000;
    SetLength(FFiles, FSize);
    FCount := 0;

    while True do begin

      FStream.Read(Entry, SizeOf(Entry));

      FNameLen := StrToIntDef('$'+Entry.FNameSize, 0);
      PackSize := StrToIntDef('$'+Entry.FileSize, 0);

      FNameLen := Ceil((110 + FNameLen) / 4);
      FNameLen := FNameLen*4 - 110;

      PackSize := Ceil(PackSize / 4);
      PackSize := 4*PackSize;

      SetLength(FName, FNameLen);
      FStream.Read(FName[1], FNameLen);
      FName := StringReplace(FName, chr(0), '', [rfReplaceAll]);

      if FCount = FSize then begin
        Inc(FSize, 1000);
        SetLength(FFiles, FSize);
      end;

      if FName = 'TRAILER!!!' then break;

      FFiles[FCount].Name := FName;
      FFiles[FCount].Offset := FStream.Position;
      FFiles[FCount].PackedSize := PackSize;
      FFiles[FCount].UnpackedSize := PackSize;
      FFiles[FCount].PackMethod := pmStore;

      Inc(FCount);

      FStream.Position := FStream.Position + PackSize;

      if FStream.Position > FStream.Size-1 then break;
    end;
  except
  end;
end;

end.

