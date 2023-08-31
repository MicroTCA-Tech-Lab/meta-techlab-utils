def jenkins_get_last_build_urls(jenkins_joburl, re_src_uri=''):
    import re, ast, urllib.request, urllib.error

    # Get build metadata of last successful build
    try:
        http_rsp = urllib.request.urlopen(f'{jenkins_joburl}/lastSuccessfulBuild/api/python')
    except urllib.error.HTTPError:
        raise RuntimeError(f'HTTP error when trying to access {jenkins_joburl}')
    build_meta = ast.literal_eval(http_rsp.read().decode('utf-8'))

    # Build ID
    build_nbr = build_meta['id']
    print(f'Last successful build of {jenkins_joburl}: #{build_nbr}')

    # Base names and server paths for build artifacts
    art_paths = [a['relativePath'] for a in build_meta['artifacts']]

    if re_src_uri:
        re_src_uri = re.compile(re_src_uri)
        art_paths = filter(re_src_uri.match, art_paths)

    return ' '.join(
            f'{jenkins_joburl}/{build_nbr}/artifact/{art_p}'
            for art_p in art_paths
        )
