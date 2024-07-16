tableextension 50200 ZYItemExt extends Item
{
    fields
    {
        field(50100; "Blob Picture"; BLOB)
        {
            Caption = 'Blob Picture';
            SubType = Bitmap;
        }
    }
}

pageextension 50200 ZYItemCardExt extends "Item Card"
{
    layout
    {
        addafter(Type)
        {
            field("ZY Picture"; Rec."Blob Picture")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        addbefore(CopyItem)
        {
            action(ResetZYPicture)
            {
                ApplicationArea = All;
                Caption = 'Reset ZY Picture';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if Rec."Blob Picture".HasValue then begin
                        Clear(Rec."Blob Picture");
                        CurrPage.SaveRecord();
                    end;
                end;
            }
            action(CopyBlobPictureToPicture)
            {
                ApplicationArea = All;
                Caption = 'Copy Blob Picture to Picture';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    InStr: InStream;
                    FileName: Text;
                begin
                    if Rec."Blob Picture".HasValue then begin
                        FileName := Rec."No." + '.png';
                        Rec."Blob Picture".CreateInStream(InStr);
                        Clear(Rec.Picture);
                        Rec.Picture.ImportStream(InStr, FileName);
                        Rec.Modify(true);
                    end;
                end;
            }
            action(CopyPictureToBlobPicture)
            {
                ApplicationArea = All;
                Caption = 'Copy Picture to Blob Picture';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    InStr: InStream;
                    OutStr: OutStream;
                    ItemTenantMedia: Record "Tenant Media";
                begin
                    if Rec.Picture.Count > 0 then begin
                        ItemTenantMedia.Get(Rec.Picture.Item(1));
                        ItemTenantMedia.CalcFields(Content);
                        ItemTenantMedia.Content.CreateInStream(InStr);
                        Rec."Blob Picture".CreateOutStream(OutStr);
                        CopyStream(OutStr, InStr);
                        Rec.Modify(true);
                    end;
                end;
            }
        }
    }
}
