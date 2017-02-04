import os, stat, sys
from String.distance import Distance as d


class Suibash:

    @staticmethod
    def execute(argv):
        if len(argv) == 0:
            print("")
            exit()
        if argv[1] == '-h':
            print("SUIBASH")
            exit()
        if argv[1] == '-hist':
            print("HISTFILE")
            exit()

        def is_executable_file(file_path):
            st = os.stat(file_path)
            return bool(st.st_mode & stat.S_IXUSR) and not os.path.isdir(file_path)

        paths = os.getenv("PATH")
        executables = []

        for path in paths.split(':'):
            if os.path.exists(path):
                # this part is suspicious
                files = list(map(lambda x: path + "/" + x, os.listdir(path)))
                executables.extend(list(filter(is_executable_file, files)))
        executables = list(map(lambda x: x.split('/')[-1], executables))

        sim = d.get_similarities(argv[1].split(' ')[0], executables, d.levenshtein, max_dist=3)
        if sim:
            print(sim, ' '.join(argv[2:]))
        else:
            print(' '.join(argv[1:]))
