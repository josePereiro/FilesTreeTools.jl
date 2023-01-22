function run_up_down_tests()
    
    TESTDIR = joinpath(tempdir(), "TEST_")
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
        for (thfrec, keepout, ref_filecount) in [
                (0.0, (dir) -> false, 11),
                (0.5, (dir) -> false, 11),
                (1.0, (dir) -> false, 11),
                (0.0, (dir) -> (basename(dir) == "sub2"), 6),
                (0.5, (dir) -> (basename(dir) == "sub2"), 6),
                (1.0, (dir) -> (basename(dir) == "sub2"), 6),
            ]
            
            @info("At", thfrec, ref_filecount)
            
            for _ in 1:10
                # all threaded
                filecounts = Dict{Int, Int}()
                walkdown(TESTDIR; keepout, thfrec) do path
                    thid = threadid()
                    get!(filecounts, thid, 0)
                    
                    isfile(path) && (filecounts[thid] += 1)
                    thfrec > 0.0 && sleep(0.1)
                    false
                end
                filecount = sum(values(filecounts))
                @show filecounts
                @test filecount == ref_filecount
            end

            println()
        end

        @info("Testing filterdown", nthreads())

        for (thfrec, filter_, keepout, ref_filecount) in [
                (0.0, isdir, (dir) -> false, 10),
                (0.5, isdir, (dir) -> false, 10),
                (1.0, isdir, (dir) -> false, 10),
                (0.0, isdir, (dir) -> (basename(dir) == "sub2"), 6),
                (0.5, isdir, (dir) -> (basename(dir) == "sub2"), 6),
                (1.0, isdir, (dir) -> (basename(dir) == "sub2"), 6),

                (0.0, isfile, (dir) -> false, 11),
                (0.5, isfile, (dir) -> false, 11),
                (1.0, isfile, (dir) -> false, 11),
                (0.0, isfile, (dir) -> (basename(dir) == "sub2"), 6),
                (0.5, isfile, (dir) -> (basename(dir) == "sub2"), 6),
                (1.0, isfile, (dir) -> (basename(dir) == "sub2"), 6),
            ]

            @info("At", thfrec, nameof(filter_), ref_filecount)

            for _ in 1:10
                arr = filterdown(filter_, TESTDIR; thfrec, keepout)
                @show isfile.(arr)
                @test length(arr) == ref_filecount
            end

            println()
        end

        @info("Testing walkup and fiterup", nthreads())

        # all
        for (dir0, ref_filecount) in [
                (joinpath(TESTDIR, "sub2", "sub21", "sub211"), 4),
                (joinpath(TESTDIR, "sub2", "sub21"), 3),
                (joinpath(TESTDIR, "sub2"), 2),
                (joinpath(TESTDIR), 1),
                
            ]
            
            @info("At", dir0, ref_filecount)
            
            # all threaded
            filecount = 0
            walkup(dir0; root = TESTDIR) do path
                isfile(path) && (filecount += 1)
                false
            end
            @show filecount
            @test filecount == ref_filecount
            
            founds = filterup(isfile, dir0; root = TESTDIR)
            filecount = length(founds)
            @test filecount == ref_filecount

            println()
        end


    finally
        rm(TESTDIR; force = true, recursive = true)
    end

end
run_up_down_tests()