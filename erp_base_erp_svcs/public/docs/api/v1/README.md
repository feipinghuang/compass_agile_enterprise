Must install apidoc

http://apidocjs.com/

and

apidoc-swagger

https://github.com/portablemind/apidoc-swagger

command to run doc generator, must be run from within the public docs directory of the engine you are preparing API docs for.

apidoc-swagger -i ../../../../../app/controllers/api/v1/ -o ./ --markdown=false