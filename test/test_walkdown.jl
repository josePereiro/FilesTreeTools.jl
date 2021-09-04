function run_walkdown_tests()
    TESTDIR = joinpath(tempdir(), "TEST_WALKDOWN")
    rm(TESTDIR; force = true, recursive = true)

    try
        # create files
        _createfile(TESTDIR, "tesfile")
        _createfile(TESTDIR, "sub1", "tesfile")
        _createfile(TESTDIR, "sub1", "sub11", "tesfile")
        _createfile(TESTDIR, "sub1", "sub11", "sub111", "tesfile")
        _createfile(TESTDIR, "sub1", "sub12", "tesfile")
        _createfile(TESTDIR, "sub1", "sub12", "sub121", "tesfile")
        _createfile(TESTDIR, "sub2", "tesfile")
        _createfile(TESTDIR, "sub2", "sub21", "tesfile")
        _createfile(TESTDIR, "sub2", "sub21", "sub211", "tesfile")
        _createfile(TESTDIR, "sub2", "sub22", "tesfile")
        _createfile(TESTDIR, "sub2", "sub22", "sub221", "tesfile")

        @info("Testing walkdown", nthreads())

        # all
        for (th, keepout, ref_filecount) in [
                (false, (dir) -> false, 11),
                (true, (dir) -> false, 11),
                (false, (dir) -> (basename(dir) == "sub2"), 6),
                (true, (dir) -> (basename(dir) == "sub2"), 6)
            ]
            
            @info("At", th, ref_filecount)
            
            for it in 1:10
                # all threaded
                filecounts = Dict{Int, Int}()
                walkdown(TESTDIR; keepout, th) do path
                    thid = threadid()
                    get!(filecounts, thid, 0)
                    
                    isfile(path) && (filecounts[thid] += 1)
                    th && sleep(0.1)
                    false
                end
                filecount = sum(values(filecounts))
                @show filecounts
                @test filecount == ref_filecount
            end

            println()
        end

    finally
        rm(TESTDIR; force = true, recursive = true)
    end

end
run_walkdown_tests()