import Options
from os import popen, unlink, symlink, getcwd
from os.path import exists

srcdir = "."
blddir = "build"
VERSION = "0.0.1"

def set_options(opt):
  opt.tool_options("compiler_cxx")

def configure(conf):
  conf.check_tool("compiler_cxx")
  conf.check_tool("node_addon")

def build(bld):
  obj = bld.new_task_gen("cxx", "shlib", "node_addon")
  obj.target = "src/binding_yajl"
  #obj.source = "src/*.cc"
  obj.find_sources_in_dirs("src")
  obj.lib = "yajl"

def shutdown(bld):
  # HACK to get binding.node out of build directory.
  # better way to do this?
  if Options.commands['clean']:
    if exists('src/binding_yajl.node'): unlink('src/binding_yajl.node')
  else:
    if exists('build/default/src/binding_yajl.node') and not exists('src/binding_yajl.node'):
      symlink(getcwd()+'/build/default/src/binding_yajl.node', 'src/binding_yajl.node')
