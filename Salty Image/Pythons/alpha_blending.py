#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Authors: Neti Rohiniesh, Owen Saviola Natadiria

# ˅
import numpy as np
import cv2
# ˄


class AlphaBlending:
    """
    Utility class housing the alpha blending function.

    Included in another class in case more processing is added in the future.
    If more functions are added, it would be cleaner to have an instantiated class that handles everything instead.


    Note:
        Alpha blending function is currently static. Can be called without creating a class instance.
        No arguments at the moment.

    """

    @staticmethod
    def apply_alpha_blending(input_paths, input_images, masked_area_multiplier, softness):
        """
        The main image blending function.

        It applies alpha blending and gamma correction to the respective edges of both images.
        It blends the input image into a black background.

        Args:
            input_paths: A list of paths to the original images. Used to check for right or left image.
            input_images: A list of opencv-read images. The output of __read_image() should be used, preferably.
            masked_area_multiplier: The percentage of area that is to be blended.
            softness: A value for adjusting the softness of the blended edges

        Returns:
            A dictionary of processed images where the index is the side (left or right) of the image.

        Examples:
            >>> AlphaBlending.apply_alpha_blending(input_paths, input_images, masked_area_multiplier, softness)
        """
        # ˅

        processed_images = {}
        for n, path in enumerate(input_paths):
            image = input_images[n]
            # Convert image array to have float values for more precise calculations.
            image = image.astype(float)
            dst = np.zeros(image.shape)
            if "right" in path.lower():
                # Only processing the part of the image that overlaps
                section_range = round(masked_area_multiplier * image.shape[1])
                for i in range(0, section_range):
                    '''
                    Alpha value is the weight of the first image to be added.
                    Starts at 1 and ends at 0 for the right image.
                    The section is brightest at the beginning and darkest at the end.
                    But since it is subtracted later, it becomes the opposite, the way it is supposed to be.
                    It works with the softness multiplier better this way.
                    '''
                    alpha = ((section_range - i + 1) / section_range) * softness
                    # Weighted addition with the weights changing every iteration for a gradual brightness variation.
                    dst[:, i] = cv2.addWeighted(image[:, i], alpha, dst[:, i], 1 - alpha, 0)
                processed_images['right'] = image - dst
            elif "left" in path.lower():
                section_range = round((1 - masked_area_multiplier) * image.shape[1])
                for j, i in enumerate(range(section_range, image.shape[1])):
                    # Alpha value starts at 0 and ends at 1 for the left image. Opposite of the right.
                    alpha = ((j + 1) / (image.shape[1] - section_range)) * softness
                    # Weighted addition with the weights changing every iteration for a gradual brightness variation.
                    dst[:, i] = cv2.addWeighted(image[:, i], alpha, dst[:, i], 1 - alpha, 0)
                processed_images['left'] = image - dst

        return processed_images
        # ˄

    # The constructor.
    def __init__(self):
        # ˅
        pass
        # ˄
