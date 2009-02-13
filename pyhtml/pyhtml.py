class XMLNode(object):
    def __init__(self, tag, *words, **attrs):
        self.tag = tag
        self.words = words
        self.attrs = attrs
        self.child_nodes = None
        
    def __call__(self, *child_nodes):
        self.child_nodes = child_nodes
        return self
        
    def __iter__(self):
        yield self
        
    def __str__(self):
        c = []
        c.append('<' + self.tag)
        if len(self.attrs) > 0:
            c.append(' ')
            c.append(" ".join(['%s="%s"' % a for a in self.attrs.items()]))
        if len(self.words) > 0:
            c.append(' ')
            c.append(" ".join([w for w in self.words]))
        c.append('>')
        if self.child_nodes:
            for n in self.child_nodes:
                if isinstance(n, (str, unicode)):
                    c.append(n)
                elif isinstance(n, XMLNode):
                    c.append(str(n))
                else:
                    c.append(str(n))
        c.append('</%s>' % self.tag)
        return ''.join(c)
    
    
html_tags = ['html', 'meta', 'head', 'body', 'div', 'title', 'span', 
        'h1', 'h2', 'h3', 'h4', 'script', 'a', 'input', 'form', 'p']
def define_tags():
    import functional
    for tag in html_tags:
        globals()[tag] = functional.partial(XMLNode, tag)
        
        
# user stuff
def include_js(url):
    return script(type="text/javascript", src=url)

def inline_js(js):
    return script(type="text/javascript")("<!--%s//-->" % js)

def text_input(**attrs):
    return input(type="text", **attrs)
    
define_tags()