# aspose_pdf_2v

An app which allows you to upload and download files.

## Getting Started

In this application, I send request to local server. AppKEY, AppSID is setup in C# application.

An app works in such case:
1. we upload a file to  storage with specific path «Folder 1/ filename»
2. After uploading, you get download button. If you press to download you download your uploaded file before
3. At the bottom, you will see reset button, which allows you to upload a file again.

The path of downloaded file is : /storage/emulated/0/Android/data/com.example.aspose_pdf_2v/files


# Packages:

file_picker - a package which allows  you to use a native file explorer to pick  file paths. It has a bunch of advantages like Uses OS default native pickers, Pick files using custom format filtering — you can provide a list of file extensions (pdf, svg, zip, etc.), different default type filtering (media, image, video, audio or any) and has a 99% popularity in pub.dev

path_provider - used for finding commonly used locations on the filesystem. In my case, I have used to save my file in storage. In pub.dev has a 100% popularity, also 80 pub point.

http - used to make HTTP requests. Library allows to make individual HTTP requests with minimal hassle.
