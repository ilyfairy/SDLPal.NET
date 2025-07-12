# ͼ�������Ŵ�ű���2��������ڲ�ֵ��
# ����Ϊ Resize-Images.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$SourceFolder,  # Դͼ��Ŀ¼
    
    [string]$OutputFolder = "ResizedImages",  # ���Ŀ¼��Ĭ��ΪԴĿ¼�µ�ResizedImages��
    
    [ValidateSet("JPG", "PNG", "BMP", "GIF", "TIF")]
    [string]$OutputFormat = "JPG"  # �����ʽ
)

# ���ر�Ҫ�ĳ���
Add-Type -AssemblyName System.Drawing

# �������Ŀ¼
$outputPath = Join-Path $SourceFolder $OutputFolder
if (-not (Test-Path $outputPath)) {
    New-Item -ItemType Directory -Path $outputPath | Out-Null
}

# ��ȡ����ͼ���ļ�
$imageFiles = Get-ChildItem -Path $SourceFolder -Include @("*.jpg", "*.jpeg", "*.png", "*.bmp", "*.gif", "*.tif") -Recurse

# ���������
$processed = 0
$total = $imageFiles.Count

foreach ($file in $imageFiles) {
    try {
        # ��ȡԭʼͼ��
        $original = [System.Drawing.Image]::FromFile($file.FullName)
        
        # �����³ߴ磨2����
        $newWidth = $original.Width * 2
        $newHeight = $original.Height * 2
        
        # ����Ŀ��λͼ
        $resized = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
        
        # ʹ������ڲ�ֵ
        $graphics = [System.Drawing.Graphics]::FromImage($resized)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
        
        # ���ƷŴ�ͼ��
        $graphics.DrawImage($original, 0, 0, $newWidth, $newHeight)
        
        # �������·��
        $outputFile = Join-Path $outputPath ($file.BaseName + "." + $OutputFormat.ToLower())
        
        # ����ͼ�񣨸��ݸ�ʽѡ���������
        switch ($OutputFormat.ToUpper()) {
            "JPG" { 
                $resized.Save($outputFile, [System.Drawing.Imaging.ImageFormat]::Jpeg)
            }
            "PNG" {
                $resized.Save($outputFile, [System.Drawing.Imaging.ImageFormat]::Png)
            }
            "BMP" {
                $resized.Save($outputFile, [System.Drawing.Imaging.ImageFormat]::Bmp)
            }
            "GIF" {
                $resized.Save($outputFile, [System.Drawing.Imaging.ImageFormat]::Gif)
            }
            "TIF" {
                $resized.Save($outputFile, [System.Drawing.Imaging.ImageFormat]::Tiff)
            }
        }
        
        # �ͷ���Դ
        $original.Dispose()
        $graphics.Dispose()
        $resized.Dispose()
        
        $processed++
        Write-Host "�Ѵ���: $($file.Name) �� $([System.IO.Path]::GetFileName($outputFile))" -ForegroundColor Green
    }
    catch {
        Write-Host "����ʧ��: $($file.Name) - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n�������! $processed/$total ��ͼ���ѷŴ�" -ForegroundColor Cyan