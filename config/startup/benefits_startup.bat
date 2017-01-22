rem benefits_startup.bat
rem batch routine to start benefits in always up service manager
path c:\progs\RailsInstaller\Ruby2.2.0\bin;c:\progs\RailsInstaller\Ruby1.9.3\bin;%path%
cd c:\Sites\davis_bacon_401k
bundle exec rails server -e production -p 4001 -b 0.0.0.0
