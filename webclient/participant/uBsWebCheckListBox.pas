unit uBsWebCheckListBox;

interface

uses
  System.SysUtils,
  System.Generics.Collections,

  JS,
  Web
  ;

type
  TBsWebCheckListBoxSelection = ( Multiple, One );

  TBsWebCheckListBoxItem = class
  private
    FText: String;
    FId: String;
    FElement: TJSElement;

  public
    property Id: String read FId write FId;
    property Text: String read FText write FText;

    property Element: TJSElement read FElement write FElement;
  end;

  TBsWebCheckListBoxItems = TObjectList<TBsWebCheckListBoxItem>;

  TBsWebCheckListBoxSelectedItems = TArray<TBsWebCheckListBoxItem>;

  TBsWebCheckListBox = class
  private
    FElement: TJSELement;
    FElementId: String;
    FItems: TBsWebCheckListBoxItems;
    FSelection: TBsWebCheckListBoxSelection;

    procedure SetElementId(const Value: String);
    function GetSelected: TBsWebCheckListBoxSelectedItems;

    function TypeForSelection( ASelection: TBsWebCheckListBoxSelection ): String;

  public
    constructor Create( AElementId: String );
    destructor Destroy; override;

    procedure Clear;
    function Add: TBsWebCheckListBoxItem;
    // this could be automated, but I opted for the manual call here
    procedure Update;

    property Selected: TBsWebCheckListBoxSelectedItems read GetSelected;

    property Selection: TBsWebCheckListBoxSelection read FSelection write FSelection;

    property ElementId: String read FElementId write SetElementId;
    property Element: TJSElement read FElement;
  end;

implementation

{ TBsWebCheckListBox }

function TBsWebCheckListBox.Add: TBsWebCheckListBoxItem;
begin
  Result := TBsWebCheckListBoxItem.Create;
  FItems.Add( Result );
end;

procedure TBsWebCheckListBox.Clear;
begin
  FItems.Clear;
end;

constructor TBsWebCheckListBox.Create(AElementId: String);
begin
  inherited Create;
  FElement := nil;
  FSelection := Multiple;

  ElementId := AElementId;
  FItems := TBsWebCheckListBoxItems.Create;
end;

destructor TBsWebCheckListBox.Destroy;
begin
  FItems.Free;

  inherited;
end;

function TBsWebCheckListBox.GetSelected: TBsWebCheckListBoxSelectedItems;
var
  LCount: Integer;
  i: Integer;
  LInput: TJSHTMLInputElement;

begin
  LCount := 0;
  SetLength( Result, LCount );

  for i := 0 to FItems.Count-1 do
  begin
    LInput := FItems[i].Element as TJSHTMLInputElement;
    if LInput.checked then
    begin
      Inc(LCount);
      SetLength( Result, LCount );
      Result[LCount-1] := FItems[i];
    end;
  end;
end;

procedure TBsWebCheckListBox.SetElementId(const Value: String);
begin
  FElementId := Value;
  FElement := document.getElementById(Value);
end;

function TBsWebCheckListBox.TypeForSelection(
  ASelection: TBsWebCheckListBoxSelection): String;
begin
  if Selection = Multiple then
  begin
    Result := 'checkbox';
  end
  else
  begin
    Result := 'radio';
  end;
end;

procedure TBsWebCheckListBox.Update;
var
  LLabel,
  LLi: TJSElement;
  LInput: TJSHTMLInputElement;
  LId: String;
  i: Integer;
  LItem: TBsWebCheckListBoxItem;
  LRandomName: String;

begin
  if Assigned( FElement ) then
  begin
    FElement.className := 'list-group';
    FElement.innerHTML := '';

    LRandomName := 'radiogroup-' + IntToStr( RANDOM(9999) );

    for i := 0 to FItems.Count-1 do
    begin
      LItem := FItems[i];

      LLi := document.createElement('li');
      LLi.className := 'list-group-item';
      FElement.appendChild(LLi);

      LInput := document.createElement('input') as TJSHTMLInputElement;
      LItem.Element := LInput;

      LInput.className := 'form-check-input me-1';
      LInput.value := '';
      LInput._type := TypeForSelection( Selection );

      LInput.name := LRandomName;
      LInput['ref'] := LItem.Id;

      LId := 'chkItemCategories' + LItem.Id;
      LInput.id := LId;

      LLabel := document.createElement('label');
      LLabel.className := 'form-check-label';
      LLabel['for'] := LId;
      LLabel.innerText := LItem.Text;

      LLi.appendChild( LInput );
      LLi.appendChild( LLabel );
    end;
  end;
end;

end.
