#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Authors: Neti Rohiniesh

# ˅
from img_readwrite import ImgReadWrite
from alpha_blending import AlphaBlending

# ˄


class MainStitch:
    """
    Main image processing class.

    This class blends the edges of the images provided to it.
    Saves the output images in the same location as the file.

    Args:
        image_paths: List. The paths to the images for soft edge blending.
        screen_size: Float. The total size of the screen. Distance from the leftmost edge of the left projector to the rightmost edge of the other projector.
        projector_distance: Float. The distance between the lenses of the two projectors.
        softness_correction: Float. A value for adjusting the softness of the blended edges

    Warning:
        image_paths must contain ONLY TWO paths.
        screen_size and projector_distance must obviously be positive.
        softness_multiplier must lie between 0 and 1.
        Requires opencv and numpy packages.

    """

    def process_image(self):
        """
        Handles the entire processing of the images when called.

        Calls all necessary functions and classes to process both images.

        Returns:
              A list of paths to two images, in the order of left, right.

        Examples:
            >>> main_stitch = MainStitch(path, screen, projector, softness)
            >>> print(main_stitch.process_image())
            '["path/1/imageleft.png", "path/2/imageright.png"]'
            >>> images = main_stitch.process_image()

        """
        print("THIS IS RUNNING")
        img_read_saver      = ImgReadWrite(self.__m_image_paths)
        input_images        = img_read_saver.read_image()
        processed_images    = AlphaBlending.apply_alpha_blending(self.__m_image_paths, input_images,
                                                                 self.__m_masked_area_multiplier,
                                                                 self.__m_softness_correction)
        return img_read_saver.save_image(processed_images, self.__m_savePath)

    # The constructor.
    def __init__(self, image_paths: list, screen_size: float, projector_distance: float, softness_correction: float, savePath):

        # List. The paths to the input images
        self.__m_image_paths            = image_paths

        # Float. The distance between the lenses of the two projectors.
        self.__m_projectorDistance      = projector_distance

        # The length of overlap between the two projected images.
        self.__m_overlap_area           = screen_size - (2 * projector_distance)

        # The percentage of overlap with respect to the size of one projected screen
        self.__m_masked_area_multiplier = self.__m_overlap_area / (projector_distance + self.__m_overlap_area)

        # Float. A value for adjusting the softness of the blended edges
        self.__m_softness_correction        = softness_correction
        
        self.__m_savePath                   = savePath
