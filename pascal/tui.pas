{$MODE OBJFPC}
unit tui;

interface

type

        TMenuItem = record
                Item: string;
                X, Y: integer;
        end;

        TMenuColor = record
                ActiveFG,
                ActiveBG,
                InactiveFG,
                InactiveBG: byte;
        end;

        TMenu = class
        private
                Itens: array of TMenuItem;
                Color: TMenuColor;
        public
                function AddItem(x,y: integer; text: string): integer;
                procedure RemoveItem(i: integer);
                function RunMenu(AcceptESC:boolean = false):integer;
                procedure SetColor(ActiveFG, ActiveBG, InactiveFG, InactiveBG: byte);

                constructor Create;
        end;

        TTui = class
        private
                FSomeVar: integer;
        public
                procedure Center(line: integer; text:string);
                function ReadText(x,y,size: byte;  padding:byte = 0; FGColor: byte = 14; BGColor: byte = 10): string;
                function ProgressBar(x,y,size:byte; min,max,value:integer; FGColor: byte = 14; BGColor: byte = 10; edit: boolean = false):integer;
        end;

implementation

uses crt;

procedure TTui.Center(line: integer; text:string);
begin
        GotoXY((ScreenWidth div 2)-(length(text) div 2),line);
        write(text);
end;

function TTui.ReadText(x,y,size: byte; padding:byte = 0; FGColor: byte = 14; BGColor: byte = 10): string;
var i:integer;
        key:char;
        text: string;
begin
        text := '';
        key := #0;
        GotoXy(x,y);
        TextColor(FGColor);
        TextBackground(BGColor);
        for i:=1 to (size + 2*padding) do
                write(' ');
        gotoxy(x+padding,y);
        while (key <> #13) do
        begin
                key := readkey;
                case key of
                        #0: key:=readkey;
                        #8: if (length(text)>0) then
                            begin
                                text := copy(text,0,length(text)-1);
                                write(#8,' ',#8);
                            end;
                        else
                        begin
                                if (length(text) < size) then
                                begin
                                        text := text + key;
                                        write(key);
                                end
                        end;
                end;
        end;


        ReadText:= text;
end;

function TTui.ProgressBar(x,y,size:byte; min,max,value:integer; FGColor: byte = 14; BGColor: byte = 10; edit: boolean = false):integer;
var vunit:real;
    i, charsfilled, charsunfilled, posvalue: byte;
    svalue, sbar:string;
begin
        vunit := (max-min)/size;
        charsfilled := round((value-min) / vunit);
        charsunfilled := size-charsfilled;
        str(value, svalue);
        posvalue := (size div 2)-(length(svalue) div 2)+1;
        sbar := '';
        for i:=1 to size do
                sbar:=sbar+' ';
        for i:=1 to length(svalue) do
                sbar[posvalue + (i-1)] := svalue[i];

        GotoXy(x,y);
        TextBackground(FGColor);
        for i:=1 to charsfilled do
                write(sbar[i]);
        TextBackground(BGColor);
        for i:=1 to charsunfilled do
                write(sbar[charsfilled+i]);

end;

function TMenu.AddItem(x,y: integer; text: string): integer;
var s:integer;
begin
        s := Length(Itens);
        setlength(Itens,s+1);
        Itens[s].x := x;
        Itens[s].y := y;
        Itens[s].item := text;
end;

procedure TMenu.RemoveItem(i: integer);
var s,j: integer;
begin
        s := Length(Itens);
        for j:=i-1 to s-1 do
                Itens[j] := Itens[j+1];
        setlength(Itens, s-1);
end;

function TMenu.RunMenu(AcceptESC:boolean = false):integer;
var     i,s, active:integer;
        key:char;
begin
        active := 1;
        s := Length(Itens);

        while (key <> #13) do
        begin
                for i:=0 to s-1 do
                begin
                        GotoXY(Itens[i].x,Itens[i].y);
                        if (i+1 = active) then
                        begin
                                TextColor(Color.ActiveFG);
                                TextBackground(Color.ActiveBG);
                        end else
                        begin
                                TextColor(Color.InactiveFG);
                                TextBackground(Color.InactiveBG);
                        end;
                        write(' < ');
                        write(Itens[i].Item);
                        write(' > ');
                end;
                key := readkey;
                if (key = #0) then
                begin
                        key := readkey;
                        if ((key = 'M') or (key = 'P') ) then
                                active := active + 1;
                        if ((key = 'H') or (key = 'K') ) then
                                active := active - 1;
                        if (active <= 0) then
                                active := s;
                        if (active > s) then
                                active := 1;
                end;
                if ((key = #27) and acceptESC) then
                begin
                        active := 0;
                        break;
                end;
        end;
        RunMenu:= active;
end;

procedure TMenu.SetColor(ActiveFG, ActiveBG, InactiveFG, InactiveBG: byte);
begin
        Color.ActiveFG := ActiveFG;
        Color.ActiveBG := ActiveBG;
        Color.InactiveFG := InactiveFG;
        Color.InactiveBG := InactiveBG;
end;

constructor TMenu.create;
begin
        Color.ActiveFG := blue;
        Color.ActiveBG := green;
        Color.InactiveFG := lightgray;
        Color.InactiveBG := white;
end;

end.
