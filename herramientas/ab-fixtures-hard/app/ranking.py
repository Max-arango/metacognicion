from utils import ordenar


def top_k(items, k):
    return ordenar(list(items))[:k]
