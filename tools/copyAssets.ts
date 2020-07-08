import shell from 'shelljs';

shell.cp('-R', 'src/views', 'bin/www/');
shell.mkdir('bin/www/log');