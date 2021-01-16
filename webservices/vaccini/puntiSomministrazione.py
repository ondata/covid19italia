import sys
import csv
import json


# Converts the JSON output of a PowerBI query to a CSV file
def extract(input_file, output_file):
    input_json = read_json(input_file)
    data = input_json["results"][0]["result"]["data"]
    dm0 = data["dsr"]["DS"][0]["PH"][0]["DM0"]
    columns_types = dm0[0]["S"]
    columns = map(lambda item: item["GroupKeys"][0]["Source"]["Property"] if item["Kind"] == 1 else item["Value"], data["descriptor"]["Select"])
    value_dicts = data["dsr"]["DS"][0].get("ValueDicts", {})

    reconstruct_arrays(columns_types, dm0)
    expand_values(columns_types, dm0, value_dicts)

    replace_newlines_with(dm0, "")
    write_csv(output_file, columns, dm0)

def read_json(file_name):
    with open(file_name) as json_config_file:
        return json.load(json_config_file)

def write_csv(output_file, columns, dm0):
    with open(output_file, "w") as csvfile:
        wrt = csv.writer(csvfile)
        wrt.writerow(columns)
        for item in dm0:
            wrt.writerow(item["C"])

def reconstruct_arrays(columns_types, dm0):
    # fixes array index by applying
    # "R" bitset to copy previous values
    # "Ø" bitset to set null values
    lenght = len(columns_types)
    for item in dm0:
        currentItem = item["C"]
        if "R" in item or "Ø" in item:
            copyBitset = item.get("R", 0)
            deleteBitSet = item.get("Ø", 0)
            for i in range(lenght):
                if is_bit_set_for_index(i, copyBitset):
                    currentItem.insert(i, prevItem[i])
                elif is_bit_set_for_index(i, deleteBitSet):
                    currentItem.insert(i, None)
        prevItem = currentItem

def is_bit_set_for_index(index, bitset):
    return (bitset >> index) & 1 == 1

# substitute indexes with actual values
def expand_values(columns_types, dm0, value_dicts):
    for (idx, col) in enumerate(columns_types):
        if "DN" in col:
            for item in dm0:
                dataItem = item["C"]
                if isinstance(dataItem[idx], int):
                    valDict = value_dicts[col["DN"]]
                    dataItem[idx] = valDict[dataItem[idx]]

def replace_newlines_with(dm0, replacement):
    for item in dm0:
        elem = item["C"]
        for i in range(len(elem)):
            if isinstance(elem[i], str):
                elem[i] = elem[i].replace("\n", replacement)

def main():
    if len(sys.argv) == 3:
        extract(sys.argv[1], sys.argv[2])
    else:
        sys.exit("Usage: python3 " + sys.argv[0] + " input_file output_file", file=sys.stderr)

if __name__ == "__main__":
    main()
