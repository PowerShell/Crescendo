return @{
    CommandNameMap = @{
        "attach"="Attach-DockerContainerStream"
        "cp"="Copy-DockerFiles"
        "create"="Create-DockerContainer"
        "diff"="Inspect-DockerFileChanges"
        "events"="Get-DockerEvents"
        "exec"="Run-DockerCommand"
        "export"="Export-DockerFilesystem"
        "history"="Show-DockerImageHistory"
        "info"="Get-DockerInformation"
        "inspect"="Inspect-DockerObject"
        "kill"="Kill-DockerContainer"
        "image ls"="Get-DockerImage"
        "image build"="Build-DockerImage"
        "image inspect"="Inspect-DockerImage"
    }

    ParameterAliasMap = @{
        "dcr-image-inspect:Image"="ID;AnotherAlias"
    }

    ArgumentCompleterMap = @{
        "dcr-image-inspect:Image"="(dcr-image-ls).ID | Where-Object { `$_ -like `"`$WordToComplete*`" }"
        "dcr-image-ls:Repository"="(dcr-image-ls).Repository | Where-Object { `$_ -like `"`$WordToComplete*`" }"
    }

    HelpLinkMap = @{
        "dcr-image-inspect"="https://docs.docker.com/engine/reference/commandline/image_inspect/"
        "dcr-image-ls"="https://docs.docker.com/engine/reference/commandline/images/"
    }

    TypeMap = @{
        'filter' = 'string'
        'list' = 'string[]'
        'strings' = 'string'
        'external-ca' = 'string'
        'duration' = 'uint'
        'ipNetSlice' = 'string'
        'node-addr' = 'string'
        'pem-file' = 'string'
        'credential-spec' = 'string'
        'command' = 'string'
        'secret' = 'string'
        'bytes' = 'string'
        'ulimit' = 'string'
    }
}