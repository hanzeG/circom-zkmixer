#!/usr/local/bin/python
# -*- coding: UTF-8 -*-
from kazoo.client import KazooClient, KazooState
import optparse
import logging

root_nodes = {}
root_path = ''
target_path = ''

def tree_zk_node(zk, node=""):
    global root_nodes
    children = zk.get_children(root_path + node)
    if len(children) < 1:
        return
    for children_node in children:
        path = node + "/" + children_node
        data, stat = zk.get(root_path + path)
        if data == None:
            data = ""
        print "  " + root_path + path + "    " + data.decode("utf-8")
        root_nodes[path] = data.decode("utf-8")
        tree_zk_node(zk, path)


def build_zk_node(zk,force):
    for tree in root_nodes:
        path = target_path + tree
        print "create path " + path
        if not zk.exists(path):
            zk.ensure_path(path)
        elif not force:
            continue
        zk.set(path, str(root_nodes[tree]))


def main():
    global root_path
    global target_path
    p = optparse.OptionParser(description="Copy zk data from one node to another node", version="0.0.1",
                              usage="-r /app/test/a -t /app/prod/b -s 192.168.221.100:2181,192.168.221.101:2181")
    p.add_option('--root', '-r', help="root node path,required")
    p.add_option('--target', '-t', help="target node path,required")
    p.add_option('--server', '-s', help="zk server address,required")
    p.add_option('--force', '-f', help="force copy node if exist deleted it,option", action='store_true')
    options, arguments = p.parse_args()
    force = False
    if options.root == None:
        logging.error('-r is required\n')
        p.print_help()
        return
    if options.target == None:
        logging.error("-t is required\n")
        p.print_help()
        return
    if options.server == None:
        logging.error("-s is required\n")
        p.print_help()
        return
    if options.force == True:
        force = True
    print 'root node  %s' % options.root
    print 'target node  %s' % options.target
    print 'server %s' % options.server
    print 'force %s' % options.force
    print ""
    zk = KazooClient(hosts=options.server, read_only=True)
    zk.start()
    if not zk.exists(options.root):
        logging.error(options.root + "not exists")
        zk.stop()
        return
    target_path = options.target
    root_path = options.root
    print "current data:"
    print ""
    tree_zk_node(zk)
    print ""
    str = raw_input("checked current data and copy node to " + target_path + " (yes/no) : ")
    if str != 'yes':
        zk.stop()
        print 'bay!'
        return
    build_zk_node(zk,force)
    zk.stop()
    print 'bay!'

if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    main()

