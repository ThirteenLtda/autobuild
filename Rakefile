require 'utilrb/rake_common'

Utilrb::Rake.hoe do
    Hoe.spec 'autobuild' do
        developer "Sylvain Joyeux", "sylvain.joyeux@m4x.org"

        self.urls         = ["http://rock-robotics.org/stable/documentation/autoproj"]
        self.summary = 'Library to handle build systems and import mechanisms'
        self.description = "Collection of classes to handle build systems (CMake, autotools, ...) and import mechanisms (tarballs, CVS, SVN, git, ...). It also offers a Rake integration to import and build such software packages. It is the backbone of the autoproj (http://rock-robotics.org/autoproj) integrated software project management tool."
        self.email = %q{rock-dev@dfki.de}

        self.extra_deps <<
            ['rake', '>= 0.7.0'] <<
            ['utilrb', '>= 1.3.3']
    end
    Rake.clear_tasks(/publish_docs/, /default/)
end

task "default"

