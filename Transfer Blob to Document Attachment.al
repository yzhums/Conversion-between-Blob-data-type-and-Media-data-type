tableextension 50202 ZYSalesHeaderExt extends "Sales Header"
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

pageextension 50202 ZYSalesOrderExt extends "Sales Order"
{
    layout
    {
        addafter("External Document No.")
        {
            field("ZY Picture"; Rec."Blob Picture")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        addbefore(Post)
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
            action(CopyBlobPictureToAttachment)
            {
                ApplicationArea = All;
                Caption = 'Copy Blob Picture to Attachment';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    InStr: InStream;

                    FileName: Text;
                    DocAttach: Record "Document Attachment";
                begin
                    if Rec."Blob Picture".HasValue then begin
                        FileName := Rec."No." + ' ' + Rec."Sell-to Customer Name";
                        Rec."Blob Picture".CreateInStream(InStr);
                        DocAttach.Init();
                        DocAttach.Validate("Table ID", Database::"Sales Header");
                        DocAttach.Validate("Document Type", Enum::"Sales Document Type"::Order);
                        DocAttach.Validate("No.", Rec."No.");
                        DocAttach.Validate("File Name", FileName);
                        DocAttach.Validate("File Extension", 'png');
                        DocAttach."Document Reference ID".ImportStream(InStr, FileName);
                        DocAttach.Insert(true);
                    end;
                end;
            }
        }
    }
}
