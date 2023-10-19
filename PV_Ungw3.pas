unit PV_Ungw3;

{$mode objfpc}{$H+}

//PV Unpack
//https://github.com/PascalVault
//Licence: MIT
//Last update: 2023-10-15
//Gateworld .GW1, .GW2. GW3

interface

uses
  Classes, SysUtils, PV_Unpack, Dialogs;

  { TUnPak }

type
  TUngw3 = class(TUnpack)
  public
    constructor Create(Str: TStream); override;
  end;


implementation

{ TUntar }

constructor TUngw3.Create(Str: TStream);
type THead = packed record
      Magic: array[0..20] of Char; //"HomeBrew File Folder" + $1A
      Padding: array[0..10] of Char;
      Version: Word;
      Count: Cardinal;
      Padding2: array[0..25] of Char;
    end;
    TEntry = packed record
      FName: array[0..11] of Char;
      Unknown: Cardinal;
      Offset: Cardinal;
      Size: Cardinal;
      Unknown2: Cardinal;
      Unknown3: Cardinal;
    end;

var Head: THead;
    Entry: TEntry;
    i: Integer;
begin
  FStream := Str;

  try
    FSize  := 1000;
    SetLength(FFiles, FSize);
    FCount := 0;

    FStream.Read(Head, SizeOf(Head));

    for i:=0 to Head.Count-1 do begin

      FStream.Read(Entry, SizeOf(Entry));

      if FCount = FSize then begin
        Inc(FSize, 1000);
        SetLength(FFiles, FSize);
      end;

      FFiles[FCount].Name := Entry.FName;
      FFiles[FCount].Offset := Entry.Offset;
      FFiles[FCount].PackedSize := Entry.Size;
      FFiles[FCount].UnpackedSize := Entry.Size;
      FFiles[FCount].PackMethod := pmStore;

      Inc(FCount);
    end;

  except
  end;
end;

end.

