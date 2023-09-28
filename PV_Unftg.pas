unit PV_Unftg;

{$mode objfpc}{$H+}

//PV Unpack
//https://github.com/PascalVault
//Licence: MIT
//Last update: 2023-09-18
//Dark Reign .FTG

interface

uses
  Classes, SysUtils, PV_Unpack, Dialogs;

  { TUnPak }

type
  TUnftg = class(TUnpack)
  public
    constructor Create(Str: TStream); override;
  end;


implementation

{ TUntar }

constructor TUnftg.Create(Str: TStream);
type THead = packed record
       Magic: array[0..3] of Char; //= BOTG
       TableOffset: Cardinal;
       TableCount: Cardinal;
    end;
    TEntry = packed record
       FName: array[0..27] of Char; 
       Offset: Cardinal;
       UnpackedSize: Cardinal;
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

    FStream.Position := Head.TableOffset;

    for i:=0 to Head.TableCount-1 do begin

      FStream.Read(Entry, SizeOf(Entry));

      if FCount = FSize then begin
        Inc(FSize, 1000);
        SetLength(FFiles, FSize);
      end;

      FFiles[FCount].Name := Entry.FName;
      FFiles[FCount].Offset := Entry.Offset;
      FFiles[FCount].PackedSize := Entry.UnpackedSize;
      FFiles[FCount].UnpackedSize := Entry.UnpackedSize;
      FFiles[FCount].PackMethod := pmStore;

      Inc(FCount);
    end;
  except
  end;
end;

end.

