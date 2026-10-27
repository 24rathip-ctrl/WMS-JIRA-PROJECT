import csv

# 1. Generate PBL Black Box Testing CSV
with open('test/black_box_results.csv', mode='r', encoding='utf-8') as infile:
    reader = csv.DictReader(infile)
    with open('test/PBL_Black_Box_Testing.csv', mode='w', newline='', encoding='utf-8') as outfile:
        fieldnames = ['Test Case ID', 'Test Scenario', 'Testing Technique', 'Input (Method & Endpoint)', 'Expected Output', 'Actual Output', 'Status']
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        writer.writeheader()
        for row in reader:
            writer.writerow({
                'Test Case ID': row['TestId'],
                'Test Scenario': row['Description'],
                'Testing Technique': row['Technique'],
                'Input (Method & Endpoint)': f"{row['Method']} {row['Endpoint']}",
                'Expected Output': f"HTTP {row['ExpectedStatus']}",
                'Actual Output': f"HTTP {row['ActualStatus']}",
                'Status': 'Pass' if row['Passed'].lower() == 'true' else 'Fail'
            })
print("PBL_Black_Box_Testing.csv generated.")

# 2. Generate PBL White Box Testing CSV
with open('test/white_box_results.csv', mode='r', encoding='utf-8') as infile:
    reader = csv.DictReader(infile)
    with open('test/PBL_White_Box_Testing.csv', mode='w', newline='', encoding='utf-8') as outfile:
        fieldnames = ['Test Case ID', 'Target Class & Method', 'Coverage Criterion', 'Logic Path / Decision Condition', 'Expected Result', 'Actual Output', 'Status']
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        writer.writeheader()
        for row in reader:
            writer.writerow({
                'Test Case ID': row['TestId'],
                'Target Class & Method': f"{row['Class']}.{row['Method']}",
                'Coverage Criterion': row['CoverageType'],
                'Logic Path / Decision Condition': row['ConditionOrPath'],
                'Expected Result': row['ExpectedBehavior'],
                'Actual Output': row['ActualBehavior'],
                'Status': 'Pass' if row['Passed'].lower() == 'true' else 'Fail'
            })
print("PBL_White_Box_Testing.csv generated.")
