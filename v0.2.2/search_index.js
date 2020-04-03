var documenterSearchIndex = {"docs":
[{"location":"#FTPServer.jl-1","page":"Home","title":"FTPServer.jl","text":"","category":"section"},{"location":"#","page":"Home","title":"Home","text":"","category":"page"},{"location":"#","page":"Home","title":"Home","text":"Modules = [FTPServer]","category":"page"},{"location":"#FTPServer.Server","page":"Home","title":"FTPServer.Server","text":"Server(\n    homedir::AbstractString=/home/travis/build/invenia/FTPServer.jl/deps/usr/ftp/data;\n    username::AbstractString=\"\",\n    password::AbstractString=\"\",\n    permissions::AbstractString=elradfmwM,\n    security::Symbol=:none,\n    force_gen_certs::Bool=true,\n    debug_command::Bool=false,\n)\n\nA Server stores settings to create a pyftpdlib server.\n\nArguments\n\nhomedir::AbstractString=/home/travis/build/invenia/FTPServer.jl/deps/usr/ftp/data: Directory where you want to store your data for the test server.\n\nKeywords\n\nusername::AbstractString=\"\": Default login username. Defaults to 'userXXXX' where 'XXXX' is a number between 1 and 9999.\npassword::AbstractStringi=\"\": Default login password. Defalts to a random string of 40 characters.\npermission::AbstractString=elradfmwM: Default user read/write permissions.\nsecurity::Symbol=:none: Security method to use for connecting (options: :none, :implicit, :explicit). Passing in :none will use FTP and passing in :implicit or :explicit will use the appropriate FTPS connection.\nforce_gen_certs::Bool=true: Force regeneration of certificate and key file.\ndebug_command::Bool=false: Print out the python command being used, for debugging purposes.\n\n\n\n\n\n","category":"type"},{"location":"#FTPServer.cleanup-Tuple{}","page":"Home","title":"FTPServer.cleanup","text":"cleanup()\n\nCleans up the default FTPServer.ROOT directory:\n\n/home/travis/build/invenia/FTPServer.jl/deps/usr/ftp/data\n/home/travis/build/invenia/FTPServer.jl/deps/usr/ftp/test.crt\n/home/travis/build/invenia/FTPServer.jl/deps/usr/ftp/test.key\n\n\n\n\n\n","category":"method"},{"location":"#FTPServer.init-Tuple{}","page":"Home","title":"FTPServer.init","text":"init()\n\nCreates a test /home/travis/build/invenia/FTPServer.jl/deps/usr/ftp/data with a few sample files if one hasn't already been setup.\n\n/home/travis/build/invenia/FTPServer.jl/deps/usr/ftp/data/test_download.txt /home/travis/build/invenia/FTPServer.jl/deps/usr/ftp/data/test_download2.txt /home/travis/build/invenia/FTPServer.jl/deps/usr/ftp/data/test_directory/`\n\n\n\n\n\n","category":"method"},{"location":"#FTPServer.serve-Tuple{Function,Vararg{Any,N} where N}","page":"Home","title":"FTPServer.serve","text":"serve(f, args...; kwargs...)\n\nPasses args and kwargs to the Server constructor and runs the function f by passing in the server instance. Upon completion the server will automatically be shutdown.\n\n\n\n\n\n","category":"method"},{"location":"#FTPServer.uri-Tuple{FTPServer.Server}","page":"Home","title":"FTPServer.uri","text":"uri(server::Server)\n\nCreate an FTP URI from an FTP server object.\n\nArguments\n\nserver::Server: FTPServer object\n\n\n\n\n\n","category":"method"}]
}