require 'autobuild/test'
require 'webrick'

class TC_TarImporter < Minitest::Test
    include Autobuild
    include WEBrick

    def setup
        super

        Autobuild.logdir = "#{tempdir}/log"
        FileUtils.mkdir_p(Autobuild.logdir)

        @datadir = File.join(tempdir, 'data')
        FileUtils.mkdir_p(@datadir)
        @tarfile = File.join(@datadir, 'tarimport.tar.gz')
        FileUtils.cp(File.join(data_dir, 'tarimport.tar.gz'), @tarfile)
        
        @cachedir = File.join(tempdir, 'cache')
    end
    
    def test_tar_mode
        assert_equal(TarImporter::Plain, TarImporter.filename_to_mode('tarfile.tar'))
        assert_equal(TarImporter::Gzip, TarImporter.filename_to_mode('tarfile.tar.gz'))
        assert_equal(TarImporter::Bzip, TarImporter.filename_to_mode('tarfile.tar.bz2'))
    end

    def test_it_sets_the_repository_id_to_the_normalized_URL
        importer = TarImporter.new "FILE://test/file"
        assert_equal "file://test/file", importer.repository_id.to_str
    end

    def test_it_sets_the_source_id_to_the_normalized_URL
        importer = TarImporter.new "FILE://test/file"
        assert_equal "file://test/file", importer.source_id.to_str
    end

    def test_it_does_not_delete_a_locally_specified_archive_on_error
        dummy_tar = File.join(@datadir, "dummy.tar")
        FileUtils.touch dummy_tar
        importer = TarImporter.new "file://#{dummy_tar}"
        pkg = Package.new 'tarimport'
        assert_raises(Autobuild::SubcommandFailed) { importer.checkout(pkg) }
        assert File.file?(dummy_tar)
    end

    def test_tar_valid_url
        assert_raises(ConfigException) {
            TarImporter.new 'ccc://localhost/files/tarimport.tar.gz', :cachedir => @cachedir
        }
    end

    def web_server
        s = HTTPServer.new :Port => 2000, :DocumentRoot => tempdir
        s.mount("/files", HTTPServlet::FileHandler, tempdir)
        Thread.new { s.start }

        yield

    ensure
        s.shutdown
    end

    def test_tar_remote
        web_server do
            # Try to get the file through the http server
            pkg = Package.new 'tarimport'
            pkg.srcdir = File.join(tempdir, 'tarimport')
            importer = TarImporter.new 'http://localhost:2000/files/data/tarimport.tar.gz',
                cachedir: @cachedir,
                update_cached_file: true

            importer.checkout(pkg)
            assert(File.directory?(pkg.srcdir))
            assert(!importer.update_cache(pkg))

            sleep 2 # The Time class have a 1-second resolution
            FileUtils.touch @tarfile
            assert(importer.update_cache(pkg))
            assert(!importer.update_cache(pkg))
        end
    end

    def test_tar_remote_notfound
        web_server do
            # Try to get the file through the http server
            pkg = Package.new 'tarimport'
            pkg.srcdir = File.join(tempdir, 'tarimport')
            importer = TarImporter.new 'http://localhost:2000/files/data/tarimport-nofile.tar.gz', :cachedir => @cachedir

            assert_raises(Autobuild::SubcommandFailed) { importer.checkout(pkg) }
        end
    end
end
 
