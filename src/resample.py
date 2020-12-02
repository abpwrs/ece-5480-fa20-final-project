import os
from pathlib import Path
from sys import argv
from PIL import Image
import numpy as np

resolution_factors = [0.5, 0.25, 0.125]
res_ids = [str(a).replace('.','').rstrip('0') for a in resolution_factors]

def resample(image_filename):
  img_path = Path(image_filename).absolute()
  dir_name = img_path.parent
  basename = img_path.stem
  ext = img_path.suffix
  assert img_path.is_file(), "not a file"
  im = Image.open(img_path)
  size = im.size

  for index, resolution_factor in enumerate(resolution_factors):
    new_size = [int(a) for a in np.floor(np.array(size) * np.array(resolution_factor))]

    res_id = f"_res-{res_ids[index]}"
    new_filename = dir_name / f"{basename}{res_id}{ext}"
    im_resized = im.resize(new_size)
    im_resized.save(new_filename)


if __name__ == "__main__":
  # resample takes in a filename, which should be the one and only CLI arg to this script
  resample(argv[1])
