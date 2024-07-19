pageextension 50202 ZYSalesOrderExt extends "Sales Order"
{
    actions
    {
        addbefore(Post)
        {
            action(CopyWorkDescriptionToAttachments)
            {
                ApplicationArea = All;
                Caption = 'Copy Work Description to Attachments';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    InStr: InStream;
                    FileName: Text;
                    DocAttach: Record "Document Attachment";
                    WorkDescriptionLine: Text;
                    TxtBuilder: TextBuilder;
                    TempBlob: Codeunit "Temp Blob";
                    OutStr: OutStream;
                begin
                    WorkDescriptionLine := '';
                    WorkDescriptionLine := Rec.GetWorkDescription();
                    if WorkDescriptionLine <> '' then begin
                        FileName := Format(CurrentDateTime, 0, '<Year><Month,2><Day,2> <Hours24,2>:<Minutes,2>');
                        TxtBuilder.AppendLine(WorkDescriptionLine);
                        TempBlob.CreateOutStream(OutStr);
                        OutStr.WriteText(TxtBuilder.ToText());
                        TempBlob.CreateInStream(InStr);
                        DocAttach.Init();
                        DocAttach.Validate("Table ID", Database::"Sales Header");
                        DocAttach.Validate("Document Type", Enum::"Sales Document Type"::Order);
                        DocAttach.Validate("No.", Rec."No.");
                        DocAttach.Validate("File Name", FileName);
                        DocAttach.Validate("File Extension", 'txt');
                        DocAttach."Document Reference ID".ImportStream(InStr, FileName);
                        DocAttach.Insert(true);
                    end
                end;
            }
        }
    }
}
