module FTPServer

import Base: Process
import Base: close
using Conda
using Compat
using Compat: @__MODULE__
using Compat.Random: randstring
using Memento
using PyCall
const LOGGER = getlogger(@__MODULE__)

const pylogging = PyNULL()
const pyopenssl_crypto = PyNULL()
const pyopenssl_SSL = PyNULL()
const pyftpdlib_authorizers = PyNULL()
const pyftpdlib_handlers = PyNULL()
const pyftpdlib_servers = PyNULL()

# Defaults from pyftpdlib example
const USER = "user"
const PASSWD = "12345"
const HOST="localhost"
const PORT = 2021
const PERM = "elradfmwM"
const DEBUG = false

const SCRIPT = abspath(dirname(@__FILE__), "server.py")
const ROOT = abspath(joinpath(dirname(dirname(@__FILE__)), "deps", "usr", "ftp"))
const HOMEDIR = joinpath(ROOT, "data")
const CERT = joinpath(ROOT, "test.crt")
const KEY = joinpath(ROOT, "test.key")
const PYTHON_CMD = joinpath(
    Conda.PYTHONDIR, Compat.Sys.iswindows() ? "python.exe" : "python"
)

function __init__()
    Memento.register(LOGGER)
    copy!(pyopenssl_crypto, pyimport_conda("OpenSSL.crypto", "OpenSSL"))
    copy!(pyopenssl_SSL, pyimport_conda("OpenSSL.SSL", "OpenSSL"))
    copy!(pyftpdlib_servers, pyimport_conda("pyftpdlib.servers", "pyftpdlib", "invenia"))

    DEBUG && pylogging[:basicConfig](level=pylogging[:DEBUG])
    mkpath(ROOT)
end


mutable struct Server
    root::AbstractString
    port::Int
    username::AbstractString
    password::AbstractString
    permissions::AbstractString
    security::Symbol
    process::Process
    io::IO
end

"""
    Server(root=$ROOT; username=$USER, password=$PASSWD, permissions=$PERM, security=:none)

A Server stores settings for create an pyftpdlib server.

# Arguments
- `root::AbstractString`: Directory where you want store credentials and data for the
  test server.

# Keywords
- `username`: Default login username
- `password`: Default login password
- `permission`: Default user read/write permissions
- `security`: Security method to use for connecting (options: `:none`, `:implicity`, `:explicity`).
  Passing in `:none` will use FTP and passing in `:implicity` or `:explicity` will use the appropriate
  FTPS connection.
"""
function Server(
    root::AbstractString=ROOT; username="", password="", permissions="elradfmwM",
    security::Symbol=:none,
)
    if isempty(username)
        username = string("user", rand(1:9999))
    end
    if isempty(password)
        password = randstring(40)
    end

    cmd = `$PYTHON_CMD $SCRIPT $username $password $root --permissions $permissions`
    if security != :none
        cmd = `$cmd --tls $security --cert-file $CERT --key-file $KEY --gen-certs TRUE`
    end
    io = Pipe()

    # Note: open(::AbstractCmd, ...) won't work here as it doesn't allow us to capture STDERR.
    process = if VERSION > v"0.7.0-DEV.4445"
        run(pipeline(cmd, stdout=io, stderr=io), wait=false)
    else
        spawn(pipeline(cmd, stdout=io, stderr=io))
    end

    line = readline(io)
    m = match(r"starting FTP.* server on .*:(?<port>\d+)", line)
    if m !== nothing
        port = parse(Int, m[:port])
        Server(root, port, username, password, permissions, security, process, io)
    else
        kill(process)
        error(line, String(readavailable(io)))  # Display traceback
    end
end

"""
    serve(f, args...; kwargs...)

Passes `args` and `kwargs` to the `Server` constructor and runs the function `f` by passing
in the `server` instance. Upon completion the `server` will automatically be shutdown.
"""
function serve(f::Function, args...; kwargs...)
    server = Server(args...; kwargs...)

    try
        f(server)
    finally
        close(server)
    end
end

hostname(server::Server) = "localhost"
port(server::Server) = server.port
username(server::Server) = server.username
password(server::Server) = server.password
close(server::Server) = kill(server.process)

localpath(server::Server, path::AbstractString) = joinpath(server.root, split(path, '/')...)

function tempfile(path::AbstractString)
    content = randstring(rand(1:100))
    open(path, "w") do fp
        write(fp, content)
    end
    return content
end

function setup_home(dir::AbstractString)
    mkdir(dir)
    tempfile(joinpath(dir, "test_download.txt"))
    tempfile(joinpath(dir, "test_download2.txt"))
    mkdir(joinpath(dir, "test_directory"))
end

"""
    init()

Creates a test $HOMEDIR with a few sample files if one hasn't already been setup.

```
$HOMEDIR/test_download.txt
$HOMEDIR/test_download2.txt
$HOMEDIR/test_directory/
````
"""
init() = isdir(FTPServer.HOMEDIR) || setup_home(FTPServer.HOMEDIR)

"""
    cleanup()

Cleans up the default FTPServer.ROOT directory:

- $HOMEDIR
- $CERT
- $KEY
"""
function cleanup()
    rm(FTPServer.HOMEDIR, recursive=true)
    isfile(FTPServer.CERT) && rm(FTPServer.CERT)
    isfile(FTPServer.KEY) && rm(FTPServer.KEY)
end

end # module
