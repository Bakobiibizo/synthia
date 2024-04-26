import subprocess
from subprocess import Popen
from typing_extensions import List
import argparse

def start_detached_process(command: List[str]):
    return subprocess.Popen(
        f"nohup {' '.join(command)} &",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        shell=True,
        text=True,
    )
def run_command(command_choice: str, args: argparse.Namespace):
    
    command = command_map[command_choice]
    process = start_detached_process(command)
    monitor_process(process)

def monitor_process(process: Popen[str]):
    """ Monitor the process output in real-time. """
    try:
        stdout, stderr = process.communicate()
        print("Output:", stdout)
        if stderr:
            print("Error:", stderr)
    except Exception as e:
        print("An error occurred:", e)

args = argparse.ArgumentParser()
args.add_argument("--ip_address", required=False, type=str, default="127.0.0.1")
args.add_argument("--port", required=False, type=int, default=5000)
args.add_argument("--netuid", required=False, type=str, default="3")
args.add_argument("--key_name", required=False, type=str, default="key")
args.add_argument("--module_path", required=False, type=str, default="synthia.miner.anthropic.AnthropicModule")
args = args.parse_args()

if __name__ == "__main__":
    run_command("serve_miner", args)
