import subprocess
import re

def parse_resource_allocations(resource_entries):
    """
    Parse resource allocation strings and convert them into dictionaries with keys being resource types and values
    being the allocated amounts. This function also handles conversion of different units (e.g., from GB to MB).

    :param resource_entries: A list of strings where each string contains comma-separated 'key=value' pairs.
    :return: A list of dictionaries with resource types and available amounts.
    """
    resource_dicts = []

    # Define a helper function to parse resource values and convert G (gigabyte) to M (megabyte) if necessary.
    def parse_resource_value(value):
        if value.endswith('G'):
            return int(value.rstrip('G')) * 1024  # Convert from GB to MB
        elif value.endswith('M'):
            return int(value.rstrip('M'))
        else:
            return int(value)

    # Process each entry
    for entry in resource_entries:
        resource_dict = {}
        resources = entry.split(',')  # Split the entry into 'key=value' components
        for r in resources:
            key, value = r.split('=')
            resource_dict[key] = parse_resource_value(value)
        resource_dicts.append(resource_dict)

    return resource_dicts

def calculate_available_resources(cfg_tres_list, alloc_tres_list):
    """
    Calculate available resources by subtracting allocated resources from config (total) resources.

    :param cfg_tres_list: A list of dictionaries containing total resources from CfgTRES field.
    :param alloc_tres_list: A list of dictionaries containing allocated resources from AllocTRES field.
    :return: A list of dictionaries with available resources for each node.
    """
    available_resources_list = []

    # Iterate through the resources and calculate differences.
    for cfg_tres, alloc_tres in zip(cfg_tres_list, alloc_tres_list):
        # Create a dictionary to hold available resources for the current node.
        available_resources = {}
        for resource, total in cfg_tres.items():
            allocated = alloc_tres.get(resource, 0)  # Default to 0 if not allocated
            available_resources[resource] = total - allocated

        available_resources_list.append(available_resources)

    return available_resources_list

def run_command(command):
    """
    Run a shell command and return the output.
    """
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    output, error = process.communicate()
    if process.returncode != 0:
        raise RuntimeError(f"Command failed with error code {process.returncode}: {error.decode().strip()}")
    return output.decode().strip()

def extract_tres_data(node_output):
    """
    Extract the CfgTRES and AllocTRES data from the command output for each node.
    :param node_output: The output from the 'scontrol -o show node' command.
    :return: Two lists, one for CfgTRES and one for AllocTRES for each node.
    """
    cfg_tres_list = []
    alloc_tres_list = []
    node_entries = node_output.strip().split('\n')

    # Regex to match CfgTRES and AllocTRES fields
    tres_regex = re.compile(r'CfgTRES=([^ ]+) AllocTRES=([^ ]+)')
    
    for entry in node_entries:
        match = tres_regex.search(entry)
        if match:
            # Extract CfgTRES and AllocTRES data
            cfg_tres, alloc_tres = match.groups()
            cfg_tres_list.append(cfg_tres)
            alloc_tres_list.append(alloc_tres)

    return cfg_tres_list, alloc_tres_list

def get_nodes(node_output):
    node_entries = node_output.strip().split('\n')
    nodes_regex = re.compile(r'NodeName=(\S+) ')
    nodes = []

    for entry in node_entries:
        match = nodes_regex.search(entry)
        if match:
            # Extract CfgTRES and AllocTRES data
            node_name = match.group(1)
            nodes.append(node_name)

    return nodes

if __name__ == '__main__':
    # Execute the scontrol command and capture its output
    command_output = run_command('scontrol -o show node')
    
    # Extract and parse the CfgTRES and AllocTRES fields from the nodes output
    cfg_tres, alloc_tres = extract_tres_data(command_output)
    
    # Parse the resource allocations
    cfg_tres_list = parse_resource_allocations(cfg_tres)
    alloc_tres_list = parse_resource_allocations(alloc_tres)
    
    # Calculate available resources for each node
    available_resources = calculate_available_resources(cfg_tres_list, alloc_tres_list)
    
    node_names = get_nodes(command_output)

    print("Free Resoureces:")
    for node, available_resources, total_resources in zip(node_names, available_resources, cfg_tres_list):
        print(f"Node: {node}")
        for res, avail in available_resources.items():
            print(f"{res.upper()}: {avail} / {total_resources[res]}")
        print()
