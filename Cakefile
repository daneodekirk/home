fs   = require 'fs'

{spawn, exec} = require 'child_process'

task 'bake', "Build CoffeeScript source files", ->
  coffee = spawn 'coffee', ['-cw', '-o', 'app', 'src']
  coffee.stdout.on 'data', (data) -> process.stderr.write data.toString()
