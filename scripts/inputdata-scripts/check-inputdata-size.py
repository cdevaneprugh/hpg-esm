import subprocess

def get_sizes(url):
    
    # Run the command in the shell, which lists file sizes from SVN.
    cmd = f'svn list --verbose --recursive "{url}" | awk \'{{print $3}}\''
    try:
        output = subprocess.check_output(cmd, shell=True, text=True)
    except subprocess.CalledProcessError as e:
        return []
   
   # Convert each line to an integer, skipping non-numeric lines.
    sizes = []
    for line in output.strip().splitlines():
        try:
            sizes.append(int(line))
        except ValueError:
            continue
    return sizes

def main():
    all_sizes = []

    # Read URLs from the file (one per line).
    with open('inputdata-addresses.txt', 'r') as f:
        urls = [line.strip() for line in f if line.strip()]

    for url in urls:
        sizes = get_sizes(url)
        all_sizes.extend(sizes)
        print(f"{url}: {sum(sizes)} bytes")

    total_bytes = sum(all_sizes)
    print("\nTotal size:", total_bytes, "bytes")
    print("Decimal GB:", round(total_bytes / 1e9), "GB")

if __name__ == '__main__':
    main()

