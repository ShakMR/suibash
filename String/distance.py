__author__ = 'tfg'


def get_most_used(plist):
    import os
    f = os.getenv("SUIBASH_HOME") + "/" + os.getenv("SUIBASH_SHELL") + "_command_usage"
    fd = open(f, 'r')
    d = {}
    for line in fd.readlines():
        line = line[:-1]
        if line in plist:
            if line in d:
                d[line] += 1
            else:
                d[line] = 0
    slist = sorted(d, key=d.get)
    if len(slist) == 0:
        return plist[0]
    return slist[0]


class Distance:
    @staticmethod
    def levenshtein(str1, str2):
        d = dict()
        for i in range(len(str1) + 1):
            d[i] = dict()
            d[i][0] = i
        for i in range(len(str2) + 1):
            d[0][i] = i
        for i in range(1, len(str1) + 1):
            for j in range(1, len(str2) + 1):
                d[i][j] = min(d[i][j - 1] + 1, d[i - 1][j] + 1, d[i - 1][j - 1] + (not str1[i - 1] == str2[j - 1]))
        return d[len(str1)][len(str2)]

    @staticmethod
    def hamming(s1, s2, codification='UTF_8'):
        """Return the Hamming distance between equal-length sequences"""
        dist = 0
        return dist + sum(bool(ord(ch1) - ord(ch2)) for ch1, ch2 in zip(s1, s2))

    @staticmethod
    def needelman(str1, str2, G=2):
        d = dict()
        for i in range(len(str1) + 1):
            d[i] = dict()
            d[i][0] = i
        for i in range(len(str2) + 1):
            d[0][i] = i
        for i in range(1, len(str1) + 1):
            for j in range(1, len(str2) + 1):
                d[i][j] = min(d[i][j - 1] + 1 + G, d[i - 1][j] + 1 + G,
                              d[i - 1][j - 1] + (not str1[i - 1] == str2[j - 1]))
        return d[len(str1)][len(str2)]

    @staticmethod
    def distance(str1, str2, sim_func, with_ham=True):
        dh = Distance.hamming(str1, str2) * with_ham
        df = sim_func(str1, str2)
        return df + dh

    @staticmethod
    def get_similarities(str1, lst, sim_func, max_dist=100, with_ham=True):
        distancies = list(map(lambda x: (x, Distance.distance(str1, x, sim_func, with_ham)), lst))
        distancies.sort(key=lambda x: (x[1], x[0]))
        mindist = min(distancies[0][1], max_dist)
        mindist_list = list(map(lambda x: x[0], filter(lambda x: x[1] <= mindist, distancies)))
        try:
            return get_most_used(mindist_list)
        except:
            return "nothing_found_handle"
            # return list
