function run_walkdown_tests()
    tersdir = joinpath(tempdir(), "TEST_WALKDOWN")
    rm(tersdir; force=true, recursive=true)

    try
        # create files
        _createfile(tersdir, "tesfile")
        _createfile(tersdir, "sub1", "tesfile")
        _createfile(tersdir, "sub1", "sub11", "tesfile")
        _createfile(tersdir, "sub1", "sub11", "sub111", "tesfile")
        _createfile(tersdir, "sub1", "sub12", "tesfile")
        _createfile(tersdir, "sub1", "sub12", "sub121", "tesfile")
        _createfile(tersdir, "sub2", "tesfile")
        _createfile(tersdir, "sub2", "sub21", "tesfile")
        _createfile(tersdir, "sub2", "sub21", "sub211", "tesfile")
        _createfile(tersdir, "sub2", "sub22", "tesfile")
        _createfile(tersdir, "sub2", "sub22", "sub221", "tesfile")

        @info("Testing walkdown", nthreads())

        # all
        for (nths, keepout, ref_filecount) in [
                (1, (dir) -> false, 11),
                (2, (dir) -> false, 11),
                (1, (dir) -> (basename(dir) == "sub2"), 6),
                (2, (dir) -> (basename(dir) == "sub2"), 6)
            ]

            # all threaded
            filecounts = Dict()
            walkdown(tersdir; keepout, nths) do path
                thid = threadid()
                get!(filecounts, thid, 0)
                
                @info("At", path, nths, thid)
                isfile(path) && (filecounts[thid] += 1)
                sleep(0.2)
                false
            end
            filecount = sum(values(filecounts))
            @test filecount == ref_filecount
        end

    finally
        rm(tersdir; force=true, recursive=true)
    end

end
run_walkdown_tests()