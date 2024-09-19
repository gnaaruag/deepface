from cog import BasePredictor, Input
import sys
import time
import shutil
import torch
import core.globals
import insightface

if not torch.cuda.is_available():
    core.globals.providers = ["CPUExecutionProvider"]
    print("gpu poor detected using cpu to run the model")

import glob
import os
from pathlib import Path
import cv2
from typing import Iterator
from subprocess import call, check_call

from core.processor import get_face_swapper, process_video, process_img
from core.utils import (
    is_img,
    detect_fps,
    set_fps,
    create_video,
    add_audio,
    extract_frames,
)
from core.config import get_face
from core.enhancer import enhance_face, get_face_enhancer


def status(string):
    print("Status: " + string)


def run_cmd(command):
    try:
        call(command, shell=True)
    except KeyboardInterrupt:
        print("Process interrupted")
        sys.exit(1)


class Predictor(BasePredictor):
    def setup(self):
        time.sleep(10)
        # check_call("nvidia-smi", shell=True)
        self.face_analyser = insightface.app.FaceAnalysis(
            name="buffalo_l", providers=core.globals.providers
        )

        if os.path.isfile("inswapper_128_fp16.onnx"):
            print("Model already downloaded")
        else:
            run_cmd(
                "wget https://github.com/facefusion/facefusion-assets/releases/download/models/inswapper_128_fp16.onnx"
            )
        if os.path.isfile("GFPGANv1.4.pth"):
            print("Model already downloaded")
        else:
            run_cmd(
                "wget https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.4.pth"
            )

        get_face_swapper()
        get_face_enhancer()
        self.face_analyser.prepare(ctx_id=0, det_size=(640, 640))
        # assert torch.cuda.is_available()

    def predict(
        self,
        source: str = Input(description="Source", default=None),
        target: str = Input(description="Target", default=None),
        reference_image: str = Input(description="Reference Image", default=None),
        keep_fps: bool = Input(description="Keep FPS", default=True),
        keep_frames: bool = Input(description="Keep Frames", default=True),
    ) -> Iterator[str]:

        print("source: ", source)
        print("target: ", target)
        print("reference_image: ", reference_image)
        print("keep_fps: ", keep_fps)
        print("keep_frames: ", keep_frames)

        if not source or not os.path.isfile(source):
            print("\n[WARNING] Please select an image containing a face.")
            return
        elif not target or not os.path.isfile(target):
            print("\n[WARNING] Please select a video/image to swap face in.")
            return

        reference_image = reference_image if reference_image else None

        face_analyser = self.face_analyser

        test_face = get_face(cv2.imread(source), face_analyser)
        if not test_face:
            print(
                "\n[WARNING] No face detected in source image. Please try with another one.\n"
            )
            return

        if is_img(target):
            output = process_img(source, target, face_analyser, reference_image)
            print(output, "predict")
            yield output
            status("swap successful!")
            return

        video_name = "output.mp4"
        output_dir = "output"
        print('here1')
        if os.path.exists(output_dir):
            shutil.rmtree(output_dir)
        print('here2')
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)

        status("detecting video's FPS...")
        fps = detect_fps(target)

        if not keep_fps and fps > 30:
            this_path = "/" + video_name + ".mp4"
            set_fps(target, this_path, 30)
            target, fps = this_path, 30
        else:
            shutil.copy(target, output_dir)

        status("extracting frames...")
        extract_frames(target, output_dir)
        frame_paths = tuple(
            sorted(
            glob.glob(os.path.join(output_dir, "*.png")),
            key=lambda x: int(os.path.basename(x).replace(".png", "")),
            )
        )
        print(frame_paths)
        status("swapping in progress...")
        start_time = time.time()
        process_video(source, frame_paths, face_analyser, reference_image)
        end_time = time.time()
        print(f"Processing time: {end_time - start_time:.2f} seconds")

        status("creating video...")
        print("video_name: ", video_name)
        output_file = create_video(video_name, fps, "output")
        print("output_file: ", output_file)
        status("adding audio...")
        output_file = add_audio("output", target.split('\\')[-1], keep_frames)
        print("output_file: ", output_file)
        print("\n\nVideo saved as:", output_file, "\n\n")
        # yield output_file
        status("swap successful!")


def main(source, target, reference_image):
    predictor = Predictor()
    predictor.setup()
    for output in predictor.predict(
        source=source,
        target=target,
        reference_image=reference_image,
    ):
        print(output)
        break
    print("done")

