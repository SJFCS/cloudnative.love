import React from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import { useBlogPost } from '@docusaurus/theme-common/internal';
import styles from './styles.module.css';
import "./style.css";

export default function BlogPostItemHeaderTitle({ className }) {
  const { metadata, isBlogPostPage } = useBlogPost();
  const { permalink, title } = metadata;
  const TitleHeading = isBlogPostPage ? 'h1' : 'h2';
  return (

    <section className="page-banner" >

      <div className="auto-container">
        <TitleHeading className={clsx(styles.title, className)} itemProp="headline">
          {isBlogPostPage ? (
            title
          ) : (
            <Link itemProp="url" to={permalink}>
              {title}
            </Link>
          )}
        </TitleHeading>
      </div>

      <div className="icon-one"></div>
      <div className="icon-two"></div>
      <div className="icon-three"></div>
      <div className="icon-four"></div>
      <div className="icon-five"></div>
      <div className="icon-six"></div>
      <div className="icon-seven"></div>
      {/* <div className="icon-eight"></div> */}

    </section>


    // <TitleHeading className={clsx(styles.title, className)} itemProp="headline">
    //   {isBlogPostPage ? (
    //     title
    //   ) : (
    //     <Link itemProp="url" to={permalink}>
    //       {title}
    //     </Link>
    //   )}
    // </TitleHeading>
  );
}
