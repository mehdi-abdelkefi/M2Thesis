import os
import csv
from collections import defaultdict

# Predefined dictionaries of row numbers (not computer indexed) with labels for each input file
input_file_1_lists = [
    {"label": "no party", "rows": [2, 3, 4, 5, 102, 103, 105, 107, 110, 111, 112, 120, 123, 127, 2422, 2618, 2618, 2654,
                                   2968, 3246, 3591, 3974, 4039, 4579, 5802, 7, 8, 9, 10, 11, 76, 78, 79, 81, 82, 83,
                                   93, 94, 97, 98, 100, 101, 4406, 4705, 6007, 6515, 2064, 5619, 5632, 3245, 3251, 19,
                                   22, 43, 44, 47, 48, 50, 52, 58, 61, 62, 65, 91, 3373, 6439, 5609, 1577, 2069, 2309,
                                   3279, 4678, 2312, 6526, 25, 26, 27, 28, 30, 31, 33, 35, 36, 38, 40, 41, 42, 4428,
                                   2262, 2683, 4096, 134, 139, 141, 142, 148, 154, 155, 349, 407, 2350, 3362, 9369,
                                   3372, 3373, 3374, 3580, 3581, 6326, 4225, 4599, 4601, 6211, 6530, 6531, 272, 307,
                                   330, 398, 401, 402, 445, 648, 649, 723, 1628, 2151, 2857, 3509, 3528, 3621, 4094,
                                   4405]},

    {"label": "RN", "rows": [23, 24, 39, 53, 70, 74, 89, 96, 104, 150, 3365, 6322, 6324, 6329, 3493, 1229, 1262, 1264,
                             1324, 915, 5623, 285, 291, 406, 458, 470, 497, 517, 535, 539, 555, 625, 643, 697, 799, 877,
                             966, 1016, 1080, 1081, 1089, 1109, 1203, 1300, 1341, 1410, 1449, 1549, 1636, 2139, 2152,
                             2153, 2177, 2185, 2189, 2304, 2335, 2339, 2370, 2375, 2382, 2511, 2535, 2541, 2600, 2849,
                             2867, 2886, 3090, 3100, 3226, 3242, 3249, 3264, 3269, 3381, 3498, 3565, 3872, 3936, 3940,
                             3996, 4148, 4329, 4338, 4344, 4582, 4666, 4671, 4777, 4834, 5087, 5132, 5339, 5495, 5543,
                             5681, 5801, 5872, 5972, 5936, 5963, 6036, 6091, 6109, 6193, 6402, 6499, 6578, 5375, 4945,
                             5843, 194, 572, 1092, 615, 1069, 3559, 411, 4677, 4688]},

    {"label": "LFI", "rows": [18, 87, 116, 3572, 4820, 3680, 679, 4647, 4648, 329, 422, 586, 588, 653, 690, 691, 698,
                              701, 706, 969, 1070, 1197, 1315, 1323, 1382, 1407, 1612, 1813, 1842, 2182, 221, 2509,
                              2675, 2845, 2894, 2924, 3434, 3508, 3608, 3629, 3840, 3848, 4302, 4324, 4527, 4647, 4704,
                              4752, 5428, 6206, 6373, 6583, 6699, 915, 1121, 1276, 3997, 4084, 5463, 5716, 217, 2182,
                              4091, 4896, 5048, 1406, 2322, 1406]},

    {"label": "LR", "rows": [32, 45, 49, 59, 63, 64, 71, 72, 75, 99, 3360, 3891, 4017, 6325, 4310, 289, 684, 974, 1004,
                             1012, 1238, 1243, 1296, 1515, 1533, 1537, 1759, 1961, 2234, 2257, 2358, 2363, 2365, 3233,
                             3346, 3356, 3360, 3576, 3583, 4066, 4380, 5049, 5263, 5466, 5488, 5797, 5850, 6419, 6460,
                             6714, 568, 950, 1455, 1986, 6501, 5045, 3816]},

    {"label": "PS", "rows": [108, 149, 960, 342, 1199, 2264, 6266, 6267, 5977, 4614, 6037, 6110]},

    {"label": "PCF", "rows": [133, 69, 66, 316, 1055, 1406, 1412, 1413, 1414, 1457, 1470, 1499, 1803, 2350, 2371, 2411,
                              3765, 5047, 5088, 6202, 6321, 6323]},

    {"label": "MoDem", "rows": [106, 113, 84, 85, 532, 1036, 1095, 1143, 1163, 1227, 1423, 1477, 2127, 2326, 2357, 2591,
                                2638, 3157, 3487, 3659, 3679, 3825, 4131, 4331, 4368, 5026, 5996, 6077, 6343, 6366,
                                6413, 6434, 6623, 6648, 2065]},

    {"label": "Agir", "rows": [218, 225, 309, 1884, 3752]},

    {"label": "UDI", "rows": [231, 272, 632, 1120, 1292, 1467, 1514, 1531, 1586, 1790, 3522, 3807, 3813, 3924, 6440]},

    {"label": "EELV", "rows": [1675, 2128, 3641, 6054]},

    {"label": "Gen", "rows": [6264, 6397]},

    {"label": "PlPublique", "rows": [1209]},

    {"label": "MRSL", "rows": [6494]},

    {"label": "GRS", "rows": [3884, 1195]}
]

input_file_2_lists = [
    {"label": "no party", "rows": [987, 1171, 795, 42, 988, 1016, 1023, 1071, 1069, 1066, 1060, 1041, 1018, 842, 833,
                                   831, 829, 819, 295, 44, 132, 185, 266, 595, 621, 634, 758]},

    {"label": "LREM", "rows": [1015, 828]},

    {"label": "LFI", "rows": [34, 48, 103, 261, 353, 339, 390, 1136, 765]},

    {"label": "Gen", "rows": [1106]},

    {"label": "PS", "rows": [368]},

    {"label": "EELV", "rows": [24, 765]}
]

input_file_3_lists = [
    {"label": "GRS", "rows": [59]},

    {"label": "no party", "rows": [561]},

    {"label": "EELV", "rows": [68]}
]

input_file_4_lists = [
    {"label": "no party", "rows": [3, 9, 12, 170, 164, 429, 441, 434, 432, 402, 415, 194, 148]},

    {"label": "RN", "rows": [23]},

    {"label": "UDI", "rows": [129]}
]

input_file_5_lists = [
    {"label": "no party", "rows": [2, 9, 21, 26, 44]}
]

input_file_6_lists = [
    {"label": "no party", "rows": [3, 4, 11, 13, 14, 27, 30, 36, 42, 47, 49, 50, 53, 55, 79, 92, 94, 106, 107, 139, 140,
                                   141, 148]},

    {"label": "EELV", "rows": [2, 37]},

    {"label": "LREM", "rows": [41]}
]

input_file_7_lists = [
    {"label": "no party", "rows": [4, 18]}
]

input_file_8_lists = [
    {"label": "PCF", "rows": [60, 116, 144]},

    {"label": "NouvDonne", "rows": [57]},

    {"label": "LFI", "rows": [44, 45]},

    {"label": "PS", "rows": [29]}
]

input_file_9_lists = [
    {"label": "no party", "rows": [3, 4, 13, 39, 87]},

    {"label": "LREM", "rows": [2]},

    {"label": "LFI", "rows": [8]}
]


# Create a dictionary to store the lists for each input file
input_list_dicts = {
    os.path.join("data", "input_file_1.csv"): input_file_1_lists,
    os.path.join("data", "input_file_2.csv"): input_file_2_lists,
    os.path.join("data", "input_file_3.csv"): input_file_3_lists,
    os.path.join("data", "input_file_4.csv"): input_file_4_lists,
    os.path.join("data", "input_file_5.csv"): input_file_5_lists,
    os.path.join("data", "input_file_6.csv"): input_file_6_lists,
    os.path.join("data", "input_file_7.csv"): input_file_7_lists,
    os.path.join("data", "input_file_8.csv"): input_file_8_lists,
    os.path.join("data", "input_file_9.csv"): input_file_9_lists,

}

# Function to filter and extract data
def filter_and_extract_data(input_file, row_number_dicts, output_data):
    with open(input_file, "r", newline='', encoding='utf-8') as csvfile:
        csvreader = csv.DictReader(csvfile)
        data = [row for row in csvreader]

    for row_number_dict in row_number_dicts:
        label = row_number_dict["label"]
        row_numbers = row_number_dict["rows"]

        # Get the corresponding "from_user_name" values for the row numbers
        user_names = [data[row_num - 1]['from_user_name'] for row_num in row_numbers if 0 < row_num <= len(data)]
        unique_user_names = set(user_names)         # Remove duplicates

        # Add the unique "from_user_name" values to the output_data for the corresponding criteria
        output_data[label].update(unique_user_names)

# Prepare a dictionary to store the output data for each criteria
output_data = defaultdict(set)

# Filter and extract data for each input file
for input_file, row_number_dicts in input_list_dicts.items():
    filter_and_extract_data(input_file, row_number_dicts, output_data)

# Write the output data to the corresponding criteria output files
for label, user_names in output_data.items():
    output_file = f"{label}_output.txt"
    with open(output_file, "w", newline='', encoding='utf-8') as txtfile:
        txtfile.write("from_user_name\n")  # Write header in the output txt file
        for user_name in user_names:
            txtfile.write(f"{user_name}\n")


