import os
import shutil

def path(string):
    return string

def run_command(command, mode="silent"):
    if mode == "debug":
        return os.system(command)
    return os.popen(command).read()


def detect_fps(input_path):
    input_path = path(input_path)
    output = os.popen(f'ffprobe -v error -select_streams v -of default=noprint_wrappers=1:nokey=1 -show_entries stream=r_frame_rate "{input_path}"').read()
    if "/" in output:
        try:
            return int(output.split("/")[0]) // int(output.split("/")[1])
        except:
            pass
    return 60


def set_fps(input_path, output_path, fps):
    input_path, output_path = path(input_path), path(output_path)
    os.system(f'ffmpeg -i "{input_path}" -filter:v fps=fps={fps} "{output_path}"')


def create_video(video_name, fps, output_dir):
    output_dir = path(output_dir)
    os.system(f'ffmpeg -framerate {fps} -i "{output_dir}/%04d.png" -c:v libx264 -pix_fmt yuv420p -y "{output_dir}/output.mp4"')
    return output_dir + f"/output.mp4"


def extract_frames(input_path, output_dir):
    input_path, output_dir = path(input_path), path(output_dir)
    os.system(f'ffmpeg -i "{input_path}" "{output_dir}/%04d.png"')


def add_audio(output_dir, target_path, keep_frames):
    video = target_path.split("/")[-1]
    video_name = video.split(".")[0]
    print(output_dir)
    print(video_name)
    # save_to = output_dir + f"/swapped-" + video_name + ".mp4"
    save_to = "output" + '/swapped-' + video_name.split('\\')[-1] + ".mp4"
    save_to_ff, output_dir_ff = path(save_to), path(output_dir)
    os.system(f'ffmpeg -i "{output_dir_ff}/output.mp4" -i "{output_dir_ff}/{video}" -c:v copy -map 0:v:0 -map 1:a:0 -y "{save_to_ff}"')
    if not os.path.isfile(save_to):
        shutil.move(output_dir + f"/output.mp4", save_to)
    if not keep_frames:
        shutil.rmtree(output_dir)
    return save_to


def is_img(path):
    return path.lower().endswith(("png", "jpg", "jpeg", "bmp"))


def rreplace(s, old, new, occurrence):
    li = s.rsplit(old, occurrence)
    return new.join(li)
