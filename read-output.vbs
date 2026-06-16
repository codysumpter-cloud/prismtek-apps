Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim repoDir
repoDir = "C:\Users\cody_\prismtek-push\prismtek-apps"

' Read validate-all-output.txt and copy to validate-result.txt
Dim src, dst
src = repoDir & "\validate-all-output.txt"
dst = repoDir & "\validate-result.txt"

If objFSO.FileExists(src) Then
    Set fIn = objFSO.OpenTextFile(src, 1)
    Dim content
    content = fIn.ReadAll()
    fIn.Close

    Set fOut = objFSO.CreateTextFile(dst, True)
    fOut.Write content
    fOut.Close
End If

' Also read validate-batch-done.txt
Dim doneSrc, doneDst
doneSrc = repoDir & "\validate-batch-done.txt"
doneDst = repoDir & "\validate-batch-done2.txt"

If objFSO.FileExists(doneSrc) Then
    Set fIn2 = objFSO.OpenTextFile(doneSrc, 1)
    Dim doneContent
    doneContent = fIn2.ReadAll()
    fIn2.Close

    Set fOut2 = objFSO.CreateTextFile(doneDst, True)
    fOut2.Write "MTIME: " & objFSO.GetFile(doneSrc).DateLastModified & vbCrLf
    fOut2.Write doneContent
    fOut2.Close
End If
