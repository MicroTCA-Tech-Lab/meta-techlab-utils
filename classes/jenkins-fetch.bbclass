def jenkins_get_last_build_urls(jenkins_url, job_name):
    import os, ast, urllib

    # Get build metadata of last successful build
    build_meta = ast.literal_eval(
        urllib.request.urlopen(f'{jenkins_url}/job/{job_name}/lastSuccessfulBuild/api/python').read().decode('utf-8'))

    # Build ID
    build_nbr = build_meta['id']
    print(f'Last successful build of {job_name}: #{build_nbr}')

    # Base names and server paths for build artifacts
    art_paths = [a['relativePath'] for a in build_meta['artifacts']]

    return ' '.join(
            f'{jenkins_url}/job/{job_name}/{build_nbr}/artifact/{art_p}'
            for art_p in art_paths
        )