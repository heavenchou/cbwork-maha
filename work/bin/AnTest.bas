Attribute VB_Name = "AnTest"
Option Explicit

Sub DoMyJob()
'XML
Dim aWord As Variant
Dim wCount, iCnt As Integer
Dim UltraEdit As Long
Dim gPath, pickW, sStr As String
gPath = "c:\cbwork\xml\"
For iCnt = 1 To Selection.Words.Count
    If Len(Selection.Words(iCnt)) <= 8 Then
        If Left(Selection.Words(iCnt), 1) = "T" Then
            gPath = gPath & Left(Selection.Words(iCnt), 3) & "\" & _
                Selection.Words(iCnt) & ".xml"
        ElseIf Left(Selection.Words(iCnt), 1) = "p" Then
            sStr = Right(Left(Selection.Words(iCnt), 8), 7)
        End If
    Else
        If Left(Selection.Words(iCnt), 1) = "T" Then
            gPath = gPath & Left(Selection.Words(iCnt), 3) & "\" & _
                Left(Selection.Words(iCnt), 9) & ".xml"
            sStr = Mid(Selection.Words(iCnt), 11, 7)
        ElseIf Left(Selection.Words(iCnt), 1) = "p" Then
            sStr = Right(Left(Selection.Words(iCnt), 8), 7)
        Else
            Exit Sub
End If
    End If
Next iCnt
If gPath = "c:\cbwork\xml\" Then
    MsgBox "你須要先選取字串", Title:="提醒"
    Exit Sub
End If
UltraEdit = Shell("UEDIT32.EXE " & gPath, vbNormalFocus)
SendKeys "^%3"
SendKeys "^ "
SendKeys "^f" & "%n" & sStr & "{ENTER}" & "%f"
'SendKeys "^f" & "%n" & sStr & "{ENTER}" & "%g" '舊版的UltraEdit
End Sub

Sub DoApp()
Dim aWord As Variant
Dim wCount, iCnt As Integer
Dim UltraEdit As Long
Dim gPath, pickW, sStr As String
gPath = "c:\release\app1\"
For iCnt = 1 To Selection.Words.Count
    If Len(Selection.Words(iCnt)) <= 8 Then
        If Left(Selection.Words(iCnt), 1) = "T" Then
            gPath = gPath & Left(Selection.Words(iCnt), 3) & "\" & _
                Selection.Words(iCnt) & ".txt"
        ElseIf Left(Selection.Words(iCnt), 1) = "p" Then
            sStr = Right(Left(Selection.Words(iCnt), 8), 7)
        End If
    Else
        If Left(Selection.Words(iCnt), 1) = "T" Then
            gPath = gPath & Left(Selection.Words(iCnt), 3) & "\" & _
                Left(Selection.Words(iCnt), 9) & ".txt"
            sStr = Mid(Selection.Words(iCnt), 11, 7)
        Else
            Exit Sub
        End If
    End If
Next iCnt
If gPath = "c:\release\app1\" Then
    MsgBox "你須要先選取字串", Title:="提醒"
    Exit Sub
End If
UltraEdit = Shell("UEDIT32.EXE " & gPath, vbNormalFocus)
SendKeys "^%3"
SendKeys "^ "
SendKeys "^f" & "%n" & sStr & "{ENTER}" & "%f"
'SendKeys "^f" & "%n" & sStr & "{ENTER}" & "%g" '舊版的UltraEdit
End Sub

Sub DoNormal()
Dim aWord As Variant
Dim wCount, iCnt As Integer
Dim UltraEdit As Long
Dim gPath, pickW, sStr As String
gPath = "c:\release\normal\"
For iCnt = 1 To Selection.Words.Count
    If Len(Selection.Words(iCnt)) <= 8 Then
        If Left(Selection.Words(iCnt), 1) = "T" Then
            gPath = gPath & Left(Selection.Words(iCnt), 3) & "\" & _
                "alltxt.txt"
        ElseIf Left(Selection.Words(iCnt), 1) = "p" Then
            sStr = Right(Left(Selection.Words(iCnt), 8), 7)
        End If
    Else
        If Left(Selection.Words(iCnt), 1) = "T" Then
            gPath = gPath & Left(Selection.Words(iCnt), 3) & "\" & _
                "alltxt.txt"
            sStr = Mid(Selection.Words(iCnt), 11, 7)
        Else
            Exit Sub
        End If
    End If
Next iCnt
If gPath = "c:\release\normal\" Then
    MsgBox "你須要先選取字串", Title:="提醒"
    Exit Sub
End If
UltraEdit = Shell("UEDIT32.EXE " & gPath, vbNormalFocus)
SendKeys "^%3"
SendKeys "^ "
SendKeys "^f" & "%n" & sStr & "{ENTER}" & "%f"
'SendKeys "^f" & "%n" & sStr & "{ENTER}" & "%g" '舊版的UltraEdit
End Sub

Sub DoRTF()
Dim iCnt As Integer
Dim DosShell As Long
Dim gPath, pickW As String

For iCnt = 1 To Selection.Words.Count
    If Len(Selection.Words(iCnt)) <= 8 Then
        If Left(Selection.Words(iCnt), 1) = "T" _
        And Mid(Selection.Words(iCnt), 4, 1) = "n" Then
            gPath = Left(Selection.Words(iCnt), 8)
        ElseIf Left(Selection.Words(iCnt), 1) = "p" Then
            pickW = Right(Selection.Words(iCnt), 7)
        End If
    Else
        If Left(Selection.Words(iCnt), 1) = "T" _
        And Mid(Selection.Words(iCnt), 4, 1) = "n" Then
'            gPath = gPath & Left(Selection.Words(iCnt), 3) & "\" & _
'                "alltxt.txt"
'            sStr = Mid(Selection.Words(iCnt), 11, 7)
        Else
            Exit Sub
        End If
    End If
Next iCnt
DosShell = Shell("c:\cbwork\work\bin\RunRTF.bat " & gPath & ".xml", vbNormalFocus)
MsgBox "Wait the dos shell to end..."
gPath = "c:\release\doc\" & Left(gPath, 3) & "\" & gPath & ".rtf"
Documents.Open FileName:=gPath
SendKeys "^%3"
SendKeys "^ "
SendKeys "^f" & pickW & "{Enter}"
SendKeys "{ESC}"
End Sub

Sub RunApp()
Dim aWord As Variant
Dim wCount, iCnt As Integer
Dim UltraEdit, RunApp As Long
Dim gPath, pickW, sStr, cmdStr As String
gPath = ""
cmdStr = "RunApp.bat "
For iCnt = 1 To Selection.Words.Count
    If Len(Selection.Words(iCnt)) <= 8 Then
        If Left(Selection.Words(iCnt), 1) = "T" Then
            gPath = gPath & Selection.Words(iCnt)
        ElseIf Left(Selection.Words(iCnt), 1) = "p" Then
            sStr = Right(Left(Selection.Words(iCnt), 8), 7)
        End If
    Else
        If Left(Selection.Words(iCnt), 1) = "T" Then
            gPath = gPath & Left(Selection.Words(iCnt), 9)
            sStr = Mid(Selection.Words(iCnt), 11, 7)
        Else
            Exit Sub
        End If
    End If
Next iCnt
If gPath = "" Then
    MsgBox "你須要先選取字串", Title:="提醒"
    Exit Sub
End If
If MsgBox("跑-n選項，請按Yes鈕" & Chr(10) & "跑-v選項，請按No鈕", vbYesNo, "App1程式選項") = vbYes Then
    cmdStr = cmdStr & Left(gPath, 3) & " -n " & gPath
Else
    cmdStr = cmdStr & Left(gPath, 3) & " -v " & Left(gPath, 3)
End If
RunApp = Shell("c:\cbwork\work\bin\" & cmdStr, vbMinimizedNoFocus)
End Sub

Sub RunNormal()
Dim aWord As Variant
Dim wCount, iCnt As Integer
Dim UltraEdit, RunApp As Long
Dim gPath, pickW, sStr, cmdStr As String
gPath = ""
cmdStr = "RunNormal.bat "
For iCnt = 1 To Selection.Words.Count
    If Len(Selection.Words(iCnt)) <= 8 Then
        If Left(Selection.Words(iCnt), 1) = "T" Then
            gPath = gPath & Selection.Words(iCnt)
        ElseIf Left(Selection.Words(iCnt), 1) = "p" Then
            sStr = Right(Left(Selection.Words(iCnt), 8), 7)
        End If
    Else
        If Left(Selection.Words(iCnt), 1) = "T" Then
            gPath = gPath & Left(Selection.Words(iCnt), 9)
            sStr = Mid(Selection.Words(iCnt), 11, 8)
        Else
            Exit Sub
        End If
    End If
Next iCnt
If gPath = "" Then
    MsgBox "你須要先選取字串", Title:="提醒"
    Exit Sub
End If
If MsgBox("跑-n選項，請按Yes鈕" & Chr(10) & "跑-v選項，請按No鈕", vbYesNo, "Normal程式選項") = vbYes Then
    cmdStr = cmdStr & Left(gPath, 3) & " -n " & gPath & ".xml"
Else
    cmdStr = cmdStr & Left(gPath, 3) & " -v " & Left(gPath, 3)
End If
RunApp = Shell("c:\cbwork\work\bin\" & cmdStr, vbMinimizedNoFocus)
End Sub

Sub ProcessAllApp()
'全文處理RunApp
Dim iCnt, RunApp As Long
Dim wCount As Integer
Dim cmdStr, gPath, hPath, sStr As String

'從游標處開始處理，而非檔案開頭
hPath = ""
wCount = 2
Selection.MoveStart unit:=wdLine, Count:=-1
Selection.MoveEnd unit:=wdLine, Count:=1
wCount = Selection.Words.Count

While wCount > 1
    gPath = ""
    cmdStr = "RunApp.bat "
    For iCnt = 1 To Selection.Words.Count
        If Len(Selection.Words(iCnt)) <= 8 Then
            If Left(Selection.Words(iCnt), 1) = "T" Then
                gPath = gPath & Selection.Words(iCnt)
            ElseIf Left(Selection.Words(iCnt), 1) = "p" Then
                sStr = Right(Left(Selection.Words(iCnt), 8), 7)
            End If
        Else
            If Left(Selection.Words(iCnt), 1) = "T" Then
                gPath = gPath & Left(Selection.Words(iCnt), 9)
                sStr = Mid(Selection.Words(iCnt), 11, 7)
            Else
                Exit Sub
            End If
        End If
    Next iCnt
    If gPath = "" Then
    '跳過這行
        Selection.MoveStart unit:=wdLine, Count:=1
        Selection.MoveEnd unit:=wdLine, Count:=1
    Else
        If gPath <> hPath Or hPath = "" Then
            cmdStr = cmdStr & Left(gPath, 3) & " -n " & gPath
            RunApp = Shell("c:\cbwork\work\bin\" & cmdStr, vbMinimizedNoFocus)
        End If
        Selection.MoveStart unit:=wdLine, Count:=1
        Selection.MoveEnd unit:=wdLine, Count:=1
        wCount = Selection.Words.Count
        hPath = gPath
    End If
    wCount = Selection.Words.Count
Wend
End Sub

Sub ProcessAllNormal()
'全文處理RunNormal
Dim iCnt, RunApp As Long
Dim wCount As Integer
Dim cmdStr, gPath, hPath, sStr As String

'從游標處開始處理，而非檔案開頭
hPath = ""
wCount = 2
Selection.MoveStart unit:=wdLine, Count:=-1
Selection.MoveEnd unit:=wdLine, Count:=1
wCount = Selection.Words.Count

While wCount > 1
    gPath = ""
    cmdStr = "RunNormal.bat "
    For iCnt = 1 To Selection.Words.Count
        If Len(Selection.Words(iCnt)) <= 8 Then
            If Left(Selection.Words(iCnt), 1) = "T" Then
                gPath = gPath & Selection.Words(iCnt)
            ElseIf Left(Selection.Words(iCnt), 1) = "p" Then
                sStr = Right(Left(Selection.Words(iCnt), 8), 7)
            End If
        Else
            If Left(Selection.Words(iCnt), 1) = "T" Then
                gPath = gPath & Left(Selection.Words(iCnt), 9)
                sStr = Mid(Selection.Words(iCnt), 11, 7)
            Else
                Exit Sub
            End If
        End If
    Next iCnt
    If gPath = "" Then
    '跳過這行
        Selection.MoveStart unit:=wdLine, Count:=1
        Selection.MoveEnd unit:=wdLine, Count:=1
        wCount = Selection.Words.Count
    Else
        If gPath <> hPath Or hPath = "" Then
            cmdStr = cmdStr & Left(gPath, 3) & " -n " & gPath & ".xml"
            RunApp = Shell("c:\cbwork\work\bin\" & cmdStr, vbMinimizedNoFocus)
        End If
        Selection.MoveStart unit:=wdLine, Count:=1
        Selection.MoveEnd unit:=wdLine, Count:=1
        wCount = Selection.Words.Count
        hPath = gPath
    End If
Wend
End Sub

Sub ProcessAllCompare(AppOrNormal As Integer)
'將目標行複製到比對行之下
Dim iCnt As Long
Dim wCount As Integer
Dim gPath, hPath, sStr, wfN, nfN, tStr As String
Dim SourceRange, TargetRange, ChkDoc As Variant

wfN = ActiveDocument.Name

'從游標處開始處理，而非檔案開頭
hPath = ""
wCount = 2
Selection.MoveStart unit:=wdLine, Count:=-1
Selection.MoveEnd unit:=wdLine, Count:=1
wCount = Selection.Words.Count

While wCount > 1
    gPath = ""
    For iCnt = 1 To Selection.Words.Count
        If Len(Selection.Words(iCnt)) <= 8 Then
            If Left(Selection.Words(iCnt), 1) = "T" Then
                gPath = gPath & Selection.Words(iCnt)
            ElseIf Left(Selection.Words(iCnt), 1) = "p" Then
                sStr = Right(Left(Selection.Words(iCnt), 8), 7)
            End If
        Else
            If Left(Selection.Words(iCnt), 1) = "T" Then
                gPath = gPath & Left(Selection.Words(iCnt), 9)
                sStr = Mid(Selection.Words(iCnt), 11, 7)
            Else
                Exit Sub
            End If
        End If
    Next iCnt

    If gPath = "" Then
        Selection.MoveStart unit:=wdLine, Count:=1
        Selection.MoveEnd unit:=wdLine, Count:=1
        wCount = Selection.Words.Count
    Else
    If AppOrNormal = vbYes Then
        tStr = "c:\release\app1\" & Left(gPath, 3) & "\" & gPath & ".txt"
    Else
        tStr = "c:\release\normal\" & Left(gPath, 3) & "\alltxt.txt"
    End If
    ChkDoc = Dir(pathname:=tStr)
    If Len(ChkDoc) = 0 Then
        MsgBox prompt:="Can't find " & tStr _
            & Chr(10) & "Please check and make sure the file exist in the path directory." _
            , Title:="提示"
    End If
    nfN = Documents.Open(FileName:=tStr)
    With Selection.Find
        .Forward = True
        .ClearFormatting
        .MatchWholeWord = False
        .MatchCase = False
        .Wrap = wdFindContinue
        .Execute FindText:=sStr
    End With
    Selection.MoveStart unit:=wdLine, Count:=-1
    Selection.MoveEnd unit:=wdLine, Count:=1
    Selection.Font.Color = wdColorRed
    Set SourceRange = Selection.Range
    SourceRange.Copy

    Documents(nfN).Close SaveChanges:=wdDoNotSaveChanges

    Documents(wfN).Activate
    Selection.Start = Selection.End
    Set TargetRange = Selection.Range
    TargetRange.Paste
    Selection.MoveStart unit:=wdLine, Count:=1
    Selection.MoveEnd unit:=wdLine, Count:=1
    wCount = Selection.Words.Count
    hPath = gPath
End If
wCount = Selection.Words.Count
Wend
End Sub

Sub ProcessAll()
Dim mStart, mEnd, mChoice As Long

mStart = Selection.Start
mEnd = Selection.End

mChoice = MsgBox("跑APP，請按Yes鈕。" & Chr(10) & "跑NORMAL，請按No鈕。" & Chr(10) _
    & "如要直接比對舊檔，請按Cancel鈕。", vbYesNoCancel, "App／Normal程式選項")
If mChoice = vbYes Then
    ProcessAllApp
ElseIf mChoice = vbNo Then
    ProcessAllNormal
Else
    mChoice = MsgBox("比對APP舊檔，請按Yes鈕。" & Chr(10) & "比對NORMAL舊檔，請按No鈕。", vbYesNo, "App／Normal程式選項─比對舊檔")
    Selection.Start = mStart
    Selection.End = mEnd
    ProcessAllCompare (mChoice)
    Exit Sub
End If

Selection.Start = mStart
Selection.End = mEnd

If MsgBox("請等程式跑完後，按Yes鈕繼續比對" & Chr(10) & "或是按No鈕停止", vbYesNo, "App／Normal程式選項") = vbYes Then
    ProcessAllCompare (mChoice)
End If

End Sub

Sub FontTest()
Dim wPick As String

Selection.Start = 1000
Selection.End = Selection.Start
Selection.MoveEnd unit:=wdWord, Count:=1
'wpick = seleciton.words
While 1
    Selection.MoveStart unit:=wdSentence, Count:=1
    Selection.MoveEnd unit:=wdSentence, Count:=1
    If MsgBox(Selection.Text & " = " & Len(Selection.Text) & Chr(10) & Selection.Start, buttons:=vbRetryCancel) = vbCancel Then
        Exit Sub
    End If
Wend
End Sub

Sub FontTest000()
Dim iCnt As Long
Dim wCount, wsCount As Integer
Dim fStr As String
Dim myRange

'Foreign1, Foreign2, Indic Times, KH2s_kj, Arial Unicode MS

Selection.Start = 0
Selection.End = Selection.Start
Selection.MoveEnd unit:=wdLine, Count:=1
'Selection.MoveEnd unit:=wdWord, Count:=-1
wCount = Selection.Words.Count

While wCount > 1
    wsCount = 0
'    fStr = ""
    For iCnt = 1 To Selection.Words.Count 'NameAscii
        Set myRange = Selection.Words(iCnt)
'        fStr = fStr & Selection.Words(iCnt) & Chr(10)
        If myRange.Font.Name = "Foreign1" _
            Or myRange.Font.Name = "Foreign2" _
            Or myRange.Font.Name = "KH2s_kj" _
            Or myRange.Font.Name = "Arial Unicode MS" Then
            myRange.Font.Name = "Indic Times"
        End If
'        fStr = fStr & "Font Name" & ": " & Selection.Words(iCnt).Font.Name & Chr(10)
'        fStr = fStr & "Font Name Ascii" & ": " & Selection.Words(iCnt).Font.NameAscii & Chr(10)
'        fStr = fStr & "Font Name Bi" & ": " & Selection.Words(iCnt).Font.NameBi & Chr(10)
'        fStr = fStr & "Font Name Far East" & ": " & Selection.Words(iCnt).Font.NameFarEast & Chr(10)
'        fStr = fStr & "Font Name Other" & ": " & Selection.Words(iCnt).Font.NameOther & Chr(10)
'        MsgBox fStr
'        fStr = ""
    Next iCnt

    ' 除非到底了，或是中間有十行以上的空行
    Selection.MoveStart unit:=wdLine, Count:=1
    Selection.MoveEnd unit:=wdLine, Count:=1
    wCount = Selection.Words.Count
    
    While wCount <= 1 And wsCount < 10
        wsCount = wsCount + 1
        Selection.MoveStart unit:=wdLine, Count:=1
        Selection.MoveEnd unit:=wdLine, Count:=1
        wCount = Selection.Words.Count
    Wend
Wend
End Sub
