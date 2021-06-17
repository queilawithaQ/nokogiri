# frozen_string_literal: true
# replacement for Hoe's task of the same name

desc "Perform a sanity check on the gemspec file list"
task :check_manifest do
  raw_gemspec = Bundler.load_gemspec("nokogiri.gemspec")

  ignore_directories = %w{
    .bundle
    .DS_Store
    .git
    .github
    .vagrant
    .yardoc
    coverage
    doc
    gems
    nokogumbo-import
    oci-images
    patches
    pkg
    ports
    rakelib
    scripts
    sorbet
    suppressions
    test
    tmp
    vendor
    [0-9]*
  }
  ignore_files = %w[
    .cross_rubies
    .editorconfig
    .gitignore
    .gitmodules
    .yardopts
    CHANGELOG.md
    CODE_OF_CONDUCT.md
    CONTRIBUTING.md
    Gemfile?*
    ROADMAP.md
    Rakefile
    SECURITY.md
    STANDARD_RESPONSES.md
    Vagrantfile
    [a-z]*.{log,out}
    [0-9]*
    appveyor.yml
    gumbo-parser/test/*
    lib/nokogiri/**/nokogiri.{jar,so}
    lib/nokogiri/nokogiri.{jar,so}
    nokogiri.gemspec
  ]

  intended_directories = Dir.children(".")
    .select { |filename| File.directory?(filename) }
    .reject { |filename| ignore_directories.any? { |ig| File.fnmatch?(ig, filename) } }

  intended_files = Dir.children(".")
    .select { |filename| File.file?(filename) }
    .reject { |filename| ignore_files.any? { |ig| File.fnmatch?(ig, filename, File::FNM_EXTGLOB) } }

  intended_files += Dir.glob(intended_directories.map { |d| File.join(d, "/**/*") })
    .select { |filename| File.file?(filename) }
    .reject { |filename| ignore_files.any? { |ig| File.fnmatch?(ig, filename, File::FNM_EXTGLOB) } }
    .sort

  spec_files = raw_gemspec.files.sort

  missing_files = intended_files - spec_files
  extra_files = spec_files - intended_files

  unless missing_files.empty?
    puts "missing:"
    missing_files.each { |f| puts "- #{f}" }
  end
  unless extra_files.empty?
    puts "unexpected:"
    extra_files.each { |f| puts "+ #{f}" }
  end
end
