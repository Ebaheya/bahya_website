import type { NextFunction, Request, Response } from 'express';
import { AppError } from '../../utils/httpError';
import {
  categoryIdParamSchema,
  categoryStatusSchema,
  createCategorySchema,
  listCategoriesQuerySchema,
  updateCategorySchema,
} from './category.schema';
import * as categoryService from './category.service';

export async function list(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const query = listCategoriesQuerySchema.parse(req.query);
    const categories = await categoryService.listCategories(query);
    res.status(200).json(categories);
  } catch (err) {
    next(err);
  }
}

export async function create(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const input = createCategorySchema.parse(req.body);
    const category = await categoryService.createCategory(input, req.user.id, req);
    res.status(201).json(category);
  } catch (err) {
    next(err);
  }
}

export async function update(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { id } = categoryIdParamSchema.parse(req.params);
    const input = updateCategorySchema.parse(req.body);
    const category = await categoryService.updateCategory(id, input, req.user.id, req);
    res.status(200).json(category);
  } catch (err) {
    next(err);
  }
}

export async function setStatus(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    if (!req.user) throw AppError.unauthorized();
    const { id } = categoryIdParamSchema.parse(req.params);
    const { isActive } = categoryStatusSchema.parse(req.body);
    const category = await categoryService.setCategoryStatus(id, isActive, req.user.id, req);
    res.status(200).json(category);
  } catch (err) {
    next(err);
  }
}
