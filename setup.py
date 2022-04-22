from distutils.core import setup
import os, py2exe, shutil, sys

sys.argv.append('py2exe')

path_dist_xshaders = os.path.join("dist", "Xshaders")
try:
    print("Deleting dist/Xshaders")
    shutil.rmtree(path_dist_xshaders)
except:
    pass
print("Copying Xshaders to dist/Xshaders")
shutil.copytree("Xshaders", path_dist_xshaders)

setup(
    options={'py2exe': {
        'bundle_files': 1,
        'compressed': True,
    }},
    console=['Xpanda.py'],
    zipfile=None,
)
