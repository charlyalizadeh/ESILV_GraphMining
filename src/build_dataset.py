import pandas as pd
from urllib.parse import unquote
from collections import defaultdict


def get_categories_dict(path):
    categories = defaultdict(list)
    with open(path, 'r') as categories_file:
        for line in categories_file.readlines()[13:]:
            article, category = line.split('\t')
            article = article.strip()
            category = category[8:]
            categories[article].append(category.strip())
    return categories

def get_categories_list(path):
    categories = []
    with open(path, 'r') as categories_file:
        for line in categories_file.readlines()[13:]:
            cat = line.split('\t')[1][8:].strip()
            if cat not in categories:
                categories.append(cat)
    return categories

def get_articles_list(path):
    with open(path, 'r') as articles_file:
        return [line.strip() for line in articles_file.readlines()[12:]]


def build_mono_partite_nodes(return_article2id=True):
    categories = get_categories_dict('data/wikispeedia_paths-and-graph/categories.tsv')
    rows = {
        'id': [],
        'name': [],
        'name_decoded': [],
        'categories': []
    }
    with open('data/wikispeedia_paths-and-graph/articles.tsv', 'r') as article_file:
        for i, article in enumerate(article_file.readlines()[12:]):
            article = article.strip()
            rows['id'].append(i)
            rows['name'].append(article)
            rows['name_decoded'].append(unquote(article))
            cat = '.'.join(categories[article])
            cat = cat if not all([c == ' ' for c in cat]) else "NaN"
            rows['categories'].append(cat)

    df = pd.DataFrame(data=rows)
    df.to_csv('data/mono_partite/articles.csv', index=False, sep=',')
    df.to_csv('data/bi_partite/articles.csv', index=False, sep=',')
    if return_article2id:
        return dict(zip(rows['name'], rows['id']))


def build_mono_partite_relationship(article2id):
    rows = {
        'id_from': [],
        'id_to': []
    }
    with open('data/wikispeedia_paths-and-graph/links.tsv', 'r') as links_file:
        for line in links_file.readlines()[12:]:
            from_art, to_art = [a.strip() for a in line.split('\t')]
            rows['id_from'].append(article2id[from_art])
            rows['id_to'].append(article2id[to_art])
    df = pd.DataFrame(data=rows)
    df['type'] = [':linked' for i in range(len(df.index))]
    df.to_csv('data/mono_partite/relationships.csv', index=False, sep=',')


def build_bi_partite_graph_article_category():
    articles = get_articles_list('data/wikispeedia_paths-and-graph/articles.tsv')
    categories = get_categories_list('data/wikispeedia_paths-and-graph/categories.tsv')
    categories_dict = get_categories_dict('data/wikispeedia_paths-and-graph/categories.tsv')
    articles2id = {article: i for i, article in enumerate(articles)}
    categories2id = {category: len(articles) + i for i, category in enumerate(categories)}
    df_articles = pd.DataFrame(
            {
                'id': list(range(len(articles))),
                'name': articles,
                'name_decoded': map(unquote, articles)
            }
    )
    df_categories = pd.DataFrame(
            {
                'id': list(range(len(articles), len(articles) + len(categories))),
                'name': map(lambda x: x.split('.')[-1], categories),
                'category': categories
            }
    )
    relationships = {
        'id_from': [],
        'id_to': []
    }
    for k, v in categories_dict.items():
        for c in v:
            relationships['id_from'].append(articles2id[k])
            relationships['id_to'].append(categories2id[c])
    df_relationships = pd.DataFrame(data=relationships)
    df_articles.to_csv('data/bi_partite_article_category/articles.csv', index=False, sep=',')
    df_categories.to_csv('data/bi_partite_article_category/categories.csv', index=False, sep=',')
    df_relationships.to_csv('data/bi_partite_article_category/relationships.csv', index=False, sep=',')


def build_bi_partite_graph_article_paths(article2id):
    # Paths
    paths = {
            'id': [],
            'timestamp': [],
            'durationInSec': [],
            'path': [],
            'rating': [],
            'state': [],
            'target': []
    }
    start_at = max([article2id[k] for k in article2id.keys()])
    with open('data/wikispeedia_paths-and-graph/paths_finished.tsv') as path_file:
        for i, line in enumerate(path_file.readlines()[16:]):
            _id, timestamp, duration, path, rating = line.strip().split('\t')
            paths['id'].append(start_at + i)
            paths['timestamp'].append(timestamp)
            paths['durationInSec'].append(duration)
            paths['path'].append(path)
            paths['rating'].append(rating)
            paths['state'].append('finished')
            paths['target'].append(path.split(';')[-1])

    start_at = max(paths['id'])
    with open('data/wikispeedia_paths-and-graph/paths_unfinished.tsv') as path_file:
        for i, line in enumerate(path_file.readlines()[17:]):
            _id, timestamp, duration, path, target, state = line.strip().split('\t')
            paths['id'].append(start_at + i)
            paths['timestamp'].append(timestamp)
            paths['durationInSec'].append(duration)
            paths['path'].append(path)
            paths['rating'].append('UNFINISHED')
            paths['state'].append(state)
            paths['target'].append(target)

    df = pd.DataFrame(data=paths)
    df.to_csv('data/bi_partite/paths.csv', index=False, sep=',')

    is_in = {
            'id_from': [],
            'id_to': []
    }
    for _id, path, target in zip(paths['id'], paths['path'], paths['target']):
        for article in path.split(';'):
            if article == '<':
                continue
            is_in['id_from'].append(article2id[article])
            is_in['id_to'].append(_id)

    pd.DataFrame(data=is_in).to_csv('data/bi_partite/is_in.csv', index=False, sep=',')


article2id = build_mono_partite_nodes()
build_mono_partite_relationship(article2id)
build_bi_partite_graph_article_paths(article2id)
