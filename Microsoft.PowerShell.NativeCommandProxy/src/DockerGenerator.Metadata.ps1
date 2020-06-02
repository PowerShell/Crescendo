return @{
    CommandNameMap = @{
        "config create"="New-DockerConfig"
        "config inspect"="Get-DockerConfigInfo"
        "config ls"="Get-DockerConfig"
        "config rm"="Remove-DockerConfig"

        "container attach"="Attach-DockerContainerStream"
        "container commit"="Commit-DockerContainer"
        "container cp"="Copy-DockerContainerFiles"
        "container create"="New-DockerContainer"
        "container diff"="Get-DockerContainerDiff"
        "container exec"="Invoke-DockerContainerCommand"
        "container export"="Export-DockerContainer"
        "container inspect"="Inspect-DockerContainer"
        "container kill"="Stop-DockerContainer"
        "container logs"="Get-DockerContainerLogs"
        "container ls"="Get-DockerContainer"
        "container pause"="Suspend-DockerContainer"
        "container port"="Get-DockerContainerPortMapping"
        "container prune"="Prune-DockerContainer"
        "container rename"="Rename-DockerContainer"
        "container restart"="Restart-DockerContainer"
        "container rm"="Remove-DockerContainer"
        "container run"="Run-DockerCommand"
        "container start"="Start-DockerContainer"
        "container stats"="Get-DockerContainerStatistics"
        "container stop"="Stop-DockerContainer"
        "container top"="Get-DockerContainerTop"
        "container unpause"="Resume-DockerContainer"
        "container update"="Update-DockerContainer"
        "container wait"="Wait-DockerContainer"
        
        "image build"="Build-DockerImage"
        "image history"="Get-DockerImageHistory"
        "image import"="Import-DockerImage"
        "image inspect"="Inspect-DockerImage"
        "image load"="Load-DockerImage"
        "image ls"="Get-DockerImage"
        "image prune"="Prune-DockerImage"
        "image pull"="Pull-DockerImage"
        "image push"="Push-DockerImage"
        "image rm"="Remove-DockerImage"
        "image save"="Save-DockerImage"
        "image tag"="New-DockerImageTag"

        "network connect"="Connect-DockerContainer"
        "network create"="New-DockerNetwork"
        "network disconnect"="Disconnect-DockerContainer"
        "network inspect"="Get-DockerNetworkInfo"
        "network ls"="Get-DockerNetwork"
        "network prune"="Prune-DockerNetwork"
        "network rm"="Remove-DockerNetwork"

        "node demote"="Demote-DockerNode"
        "node inspect"="Get-DockerNodeInfo"
        "node ls"="Get-DockerNode"
        "node promote"="New-DockerManagerNode"
        "node ps"="Get-DockerNodeTasks"
        "node rm"="Remove-DockerNode"
        "node update"="Update-DockerNode"

        "plugin create"="New-DockerPlugin"
        "plugin disable"="Disable-DockerPlugin"
        "plugin enable"="Enable-DockerPlugin"
        "plugin inspect"="Get-DockerPluginInfo"
        "plugin install"="Install-DockerPlugin"
        "plugin ls"="Get-DockerPlugin"
        "plugin push"="Push-DockerPlugin"
        "plugin rm"="Remove-DockerPlugin"
        "plugin set"="Set-DockerPlugin"
        "plugin upgrade"="Upgrade-DockerPlugin"

        "secret create"="New-DockerSecret"
        "secret inspect"="Get-DockerSecretInfo"
        "secret ls"="Get-DockerSecret"
        "secret rm"="Remove-DockerSecret"

        "service create"="New-DockerService"
        "service inspect"="Get-DockerServiceInfo"
        "service logs"="Get-DockerServiceLogs"
        "service ls"="Get-DockerService"
        "service ps"="Get-DockerServiceTasks"
        "service rm"="Remove-DockerService"
        "service rollback"="Restore-DockerService"
        "service scale"="Scale-DockerService"
        "service update"="Update-DockerService"

        "stack deploy"="New-DockerStack"
        "stack ls"="Get-DockerStack"
        "stack ps"="Get-DockerStackTasks"
        "stack rm"="Remove-DockerStack"
        "stack services"="Get-DockerStackServices"

        "swarm ca"="Get-DockerSwarmRootCA"
        "swarm init"="New-DockerSwarm"
        "swarm join"="Join-DockerSwarm"
        "swarm join-token"="Set-DockerSwarmJoinToken"
        "swarm leave"="Leave-DockerSwarm"
        "swarm unlock"="Unlock-DockerSwarm"
        "swarm unlock-key"="Set-DockerSwarmUnlockKey"
        "swarm update"="Update-DockerSwarm"

        "system df"="Get-DockerDiskUsage"
        "system events"="Get-DockerEvents"
        "system info"="Get-DockerInfo"
        "system prune"="Prune-Docker"

        "trust inspect"="Get-DockerTrustInfo"
        "trust revoke"="Remove-DockerImageTrust"
        "trust sign"="Sign-DockerImage"

        "volume create"="New-DockerVolume"
        "volume inspect"="Get-DockerVolumeInfo"
        "volume ls"="Get-DockerVolume"
        "volume prune"="Prune-DockerVolume"
        "volume rm"="Remove-DockerVolume"

        "builder prune"="Remove-DockerBuildCache"

        "inspect"="Get-DockerObjectInfo"
        "login"="Login-DockerRegistry"
        "logout"="Logout-DockerRegistry"
        "search"="Get-DockerHubImage"
        "version"="Get-DockerVersion"
    }

    SkipCommands = @( # all these are aliases for other commands
        "attach" # container attach
        "build"  # image build
        "commit" # container commit
        "cp"     # container cp
        "create" # container create
        "diff"   # container diff
        "events" # system events
        "exec"   # container exec
        "export" # container export
        "history"# image history
        "images" # image ls
        "import" # image import
        "info"   # system info
        "kill"   # container kill
        "load"   # image load
        "logs"   # container logs
        "pause"  # container pause
        "port"   # container port
        "ps"     # container ps
        "pull"   # image pull
        "push"   # image push
        "rename" # container rename
        "restart"# container restart
        "rm"     # container rm
        "rmi"    # image rm
        "run"    # container run
        "save"   # image save
        "start"  # container start
        "stats"  # container stats
        "stop"   # container stop
        "tag"    # image tag
        "top"    # container top
        "unpause"# container unpause
        "update" # container update
        "wait"   # container wait
    )

    ParameterAliasMap = @{
        "dcr-container-create:Image"="ID"
        "dcr-container-start:Container"="ID"
        "dcr-container-run:Image"="ID"
        "dcr-container-inspect:Container"="ID"
        "dcr-container-logs:Container"="ID"
        "dcr-container-stop:Container"="ID"
        "dcr-container-kill:Container"="ID"
        "dcr-container-rm:Container"="ID"

        "dcr-image-history:Image"="ID"
        "dcr-image-inspect:Image"="ID"
        "dcr-image-rm:Image"="ID"
    }

    ArgumentCompleterMap = @{
        "dcr-container-create:Image"="dcr-image-ls -All | % {`"'`$(`$_.Repository) | `$(`$_.Tag) | `$(`$_.Size) | `$(`$_.CreatedAt) | `$(`$_.ID)'`"} | Where-Object { Write-Verbose `$_;Write-Verbose `$WordToComplete;`$_ -like `"'`$WordToComplete*`" }"
        "dcr-container-start:Container"="dcr-container-ls -All | % {`"'`$(`$_.Command) | `$(`$_.Names) | `$(`$_.Status) | `$(`$_.CreatedAt) | `$(`$_.ID)'`"} | Where-Object { Write-Verbose `$_;Write-Verbose `$WordToComplete;`$_ -like `"'`$WordToComplete*`" }"
        "dcr-container-run:Image"="dcr-image-ls -All | % {`"'`$(`$_.Repository) | `$(`$_.Tag) | `$(`$_.Size) | `$(`$_.CreatedAt) | `$(`$_.ID)'`"} | Where-Object { Write-Verbose `$_;Write-Verbose `$WordToComplete;`$_ -like `"'`$WordToComplete*`" }"
        "dcr-container-inspect:Container"="dcr-container-ls -All | % {`"'`$(`$_.Command) | `$(`$_.Names) | `$(`$_.Status) | `$(`$_.CreatedAt) | `$(`$_.ID)'`"} | Where-Object { Write-Verbose `$_;Write-Verbose `$WordToComplete;`$_ -like `"'`$WordToComplete*`" }"
        "dcr-container-logs:Container"="dcr-container-ls -All | % {`"'`$(`$_.Command) | `$(`$_.Names) | `$(`$_.Status) | `$(`$_.CreatedAt) | `$(`$_.ID)'`"} | Where-Object { Write-Verbose `$_;Write-Verbose `$WordToComplete;`$_ -like `"'`$WordToComplete*`" }"
        "dcr-container-stop:Container"="dcr-container-ls -All | % {`"'`$(`$_.Command) | `$(`$_.Names) | `$(`$_.Status) | `$(`$_.CreatedAt) | `$(`$_.ID)'`"} | Where-Object { Write-Verbose `$_;Write-Verbose `$WordToComplete;`$_ -like `"'`$WordToComplete*`" }"
        "dcr-container-kill:Container"="dcr-container-ls -All | % {`"'`$(`$_.Command) | `$(`$_.Names) | `$(`$_.Status) | `$(`$_.CreatedAt) | `$(`$_.ID)'`"} | Where-Object { Write-Verbose `$_;Write-Verbose `$WordToComplete;`$_ -like `"'`$WordToComplete*`" }"
        "dcr-container-rm:Container"="dcr-container-ls -All | % {`"'`$(`$_.Command) | `$(`$_.Names) | `$(`$_.Status) | `$(`$_.CreatedAt) | `$(`$_.ID)'`"} | Where-Object { Write-Verbose `$_;Write-Verbose `$WordToComplete;`$_ -like `"'`$WordToComplete*`" }"

        "dcr-image-ls:Repository"="(dcr-image-ls -All).Repository | Where-Object { `$_ -like `"`$WordToComplete*`" }"
        "dcr-image-history:Image"="dcr-image-ls -All | % {`"'`$(`$_.Repository) | `$(`$_.Tag) | `$(`$_.Size) | `$(`$_.CreatedAt) | `$(`$_.ID)'`"} | Where-Object { Write-Verbose `$_;Write-Verbose `$WordToComplete;`$_ -like `"'`$WordToComplete*`" }"
        "dcr-image-inspect:Image"="dcr-image-ls -All | % {`"'`$(`$_.Repository) | `$(`$_.Tag) | `$(`$_.Size) | `$(`$_.CreatedAt) | `$(`$_.ID)'`"} | Where-Object { Write-Verbose `$_;Write-Verbose `$WordToComplete;`$_ -like `"'`$WordToComplete*`" }"
        "dcr-image-rm:Image"="dcr-image-ls -All | % {`"'`$(`$_.Repository) | `$(`$_.Tag) | `$(`$_.Size) | `$(`$_.CreatedAt) | `$(`$_.ID)'`"} | Where-Object { Write-Verbose `$_;Write-Verbose `$WordToComplete;`$_ -like `"'`$WordToComplete*`" }"
    }

    HelpLinkMap = @{
        "dcr-container-create"="https://docs.docker.com/engine/reference/commandline/container_create/"
        "dcr-container-start"="https://docs.docker.com/engine/reference/commandline/container_start/"
        "dcr-container-run"="https://docs.docker.com/engine/reference/commandline/container_run/"
        "dcr-container-ls"="https://docs.docker.com/engine/reference/commandline/container_ls/"
        "dcr-container-inspect"="https://docs.docker.com/engine/reference/commandline/container_inspect/"
        "dcr-container-logs"="https://docs.docker.com/engine/reference/commandline/container_logs/"
        "dcr-container-stop"="https://docs.docker.com/engine/reference/commandline/container_stop/"
        "dcr-container-kill"="https://docs.docker.com/engine/reference/commandline/container_kill/"
        "dcr-container-rm"="https://docs.docker.com/engine/reference/commandline/container_rm/"

        "dcr-image-build"="https://docs.docker.com/engine/reference/commandline/image_build/"
        "dcr-image-push"="https://docs.docker.com/engine/reference/commandline/image_push/"
        "dcr-image-ls"="https://docs.docker.com/engine/reference/commandline/images/"
        "dcr-image-history"="https://docs.docker.com/engine/reference/commandline/image_history/"
        "dcr-image-inspect"="https://docs.docker.com/engine/reference/commandline/image_inspect/"
        "dcr-image-rm"="https://docs.docker.com/engine/reference/commandline/image_rm/"

        "dcr-version"="https://docs.docker.com/engine/reference/commandline/version/"
        "dcr-login"="https://docs.docker.com/engine/reference/commandline/login/"

        "dcr-system-prune"="https://docs.docker.com/engine/reference/commandline/system_prune/"
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
        'mount' = 'string'
        'map' = 'string'
        'config' = 'string'
        'network' = 'string'
        'pref' = 'string'
        'port' = 'string'
    }
}
