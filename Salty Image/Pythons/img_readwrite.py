#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Authors: Neti Rohiniesh

# ˅
import cv2
import os
# ˄


class ImgReadWrite:
    """
    Class that handles image reading and writing

    Uses opencv for both since the image processing involves opencv.

    Args:
        input_paths: The input paths of the images

    """

    def read_image(self):
        """
        Reads the images.

        Reads images using opencv's imread function. Uses the paths provided while initializing the class.

        Returns:
            A list of numpy matrices containing the images in the order in which they were provided.

        Examples:
            >>> img_read_write = ImgReadWrite(path)
            >>> img_read_write.read_image()

        """
        # ˅
        list_of_images = []
        for path in self.__m_input_paths:
            list_of_images.append(cv2.imread(path))
        return list_of_images
        # ˄

    @staticmethod
    def save_image(processed_images, savePath):
        """
        Saves the image in the same directory as the file using opencv.

        Args:
            processed_images: Dictionary of processed images to be saved. The output of __apply_alpha_gamma_blending(), preferably.

        Returns:
            A list of paths to the processed images in the order of left, right. Same return value as process_image()

        Example:
            >>> ImgReadWrite.save_image(processed_images)

        """
        # ˅
        # Filenames are stored in a list for easier name-switching in case it is required.
        corrected_filenames = ["corrected_left.png", "corrected_right.png"]
        cv2.imwrite(f"{savePath}/{corrected_filenames[0]}", processed_images['left'])
        cv2.imwrite(f"{savePath}/{corrected_filenames[1]}", processed_images['right'])
        return ["{}/{}".format(savePath, corrected_filenames[0]),
                "{}/{}".format(savePath, corrected_filenames[1])]
        # ˄

    # The constructor.
    def __init__(self, input_paths):

        # ˅
        self.__m_input_paths = input_paths
        # ˄
